"""
User Data Processor - Python Translation
This is a Python translation of the Java UserDataProcessor class.
The function demonstrates various Python programming concepts:
- List comprehensions and generator expressions
- Lambda functions
- Exception handling
- Data transformation
- Sorting and filtering
- String manipulation
- Date/time processing
- Type hints
- Dataclasses
"""

import logging
from datetime import datetime, timedelta
from dataclasses import dataclass, field
from typing import List, Dict, Optional, Any
from collections import Counter
from enum import Enum

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class Role(Enum):
    """User roles enumeration"""
    USER = "USER"
    ADMIN = "ADMIN"

@dataclass
class User:
    """User model class"""
    id: Optional[int] = None
    email: Optional[str] = None
    password: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    role: Role = Role.USER
    enabled: bool = True
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

@dataclass
class UserAnalysisResult:
    """Result class for user data analysis"""
    total_users: int = 0
    active_users: int = 0
    inactive_users: int = 0
    role_distribution: Dict[Role, float] = field(default_factory=dict)
    top_email_domains: List[str] = field(default_factory=list)
    creation_by_month: Dict[str, int] = field(default_factory=dict)
    recent_users: int = 0
    average_name_length: float = 0.0
    potential_issues: List[str] = field(default_factory=list)
    processing_timestamp: datetime = field(default_factory=datetime.now)
    
    @classmethod
    def empty(cls) -> 'UserAnalysisResult':
        """Create an empty analysis result"""
        return cls(
            total_users=0,
            active_users=0,
            inactive_users=0,
            recent_users=0,
            average_name_length=0.0,
            processing_timestamp=datetime.now()
        )

class UserDataProcessingException(Exception):
    """Custom exception for user data processing errors"""
    pass

class UserDataProcessor:
    """User Data Processor - Python implementation"""
    
    MIN_AGE = 18
    MAX_AGE = 100
    
    def process_user_data(self, users: List[User], filters: Optional[Dict[str, Any]] = None) -> UserAnalysisResult:
        """
        Process and analyze user data with various operations
        This is the Python translation of the Java function
        
        Args:
            users: List of users to process
            filters: Optional filters to apply
            
        Returns:
            Processed user statistics and analysis
            
        Raises:
            UserDataProcessingException: If processing fails
        """
        try:
            logger.info(f"Starting user data processing for {len(users)} users")
            
            # Validate input
            if not users:
                logger.warning("No users provided for processing")
                return UserAnalysisResult.empty()
            
            # Apply filters if provided
            filtered_users = self._apply_filters(users, filters)
            logger.info(f"Applied filters, {len(filtered_users)} users remaining")
            
            # Calculate basic statistics
            total_users = len(filtered_users)
            active_users = sum(1 for user in filtered_users if user.enabled)
            
            # Group users by role
            users_by_role = {}
            for user in filtered_users:
                role = user.role
                if role not in users_by_role:
                    users_by_role[role] = []
                users_by_role[role].append(user)
            
            # Calculate role distribution
            role_distribution = {
                role: (len(user_list) / total_users) * 100
                for role, user_list in users_by_role.items()
            }
            
            # Find most common email domains
            email_domains = []
            for user in filtered_users:
                domain = self._extract_email_domain(user.email)
                if domain:
                    email_domains.append(domain)
            
            domain_counter = Counter(email_domains)
            top_domains = [domain for domain, _ in domain_counter.most_common(5)]
            
            # Analyze user creation patterns
            creation_by_month = {}
            for user in filtered_users:
                month = self._format_creation_month(user.created_at)
                if month:
                    creation_by_month[month] = creation_by_month.get(month, 0) + 1
            
            # Find recent active users (created in last 30 days)
            thirty_days_ago = datetime.now() - timedelta(days=30)
            recent_users = sum(
                1 for user in filtered_users 
                if user.created_at and user.created_at > thirty_days_ago
            )
            
            # Calculate average name length
            name_lengths = [self._calculate_name_length(user) for user in filtered_users]
            avg_name_length = sum(name_lengths) / len(name_lengths) if name_lengths else 0.0
            
            # Find users with potential issues
            potential_issues = self._identify_potential_issues(filtered_users)
            
            # Create analysis result
            result = UserAnalysisResult(
                total_users=total_users,
                active_users=active_users,
                inactive_users=total_users - active_users,
                role_distribution=role_distribution,
                top_email_domains=top_domains,
                creation_by_month=creation_by_month,
                recent_users=recent_users,
                average_name_length=avg_name_length,
                potential_issues=potential_issues,
                processing_timestamp=datetime.now()
            )
            
            logger.info("User data processing completed successfully")
            return result
            
        except Exception as e:
            logger.error("Error processing user data", exc_info=True)
            raise UserDataProcessingException("Failed to process user data") from e
    
    def _apply_filters(self, users: List[User], filters: Optional[Dict[str, Any]]) -> List[User]:
        """Apply filters to user list"""
        if not filters:
            return users
        
        filtered_users = []
        for user in users:
            # Filter by role
            if "role" in filters:
                filter_role = filters["role"]
                if user.role != filter_role:
                    continue
            
            # Filter by active status
            if "active" in filters:
                active_filter = filters["active"]
                if user.enabled != active_filter:
                    continue
            
            # Filter by email domain
            if "emailDomain" in filters:
                domain_filter = filters["emailDomain"]
                user_domain = self._extract_email_domain(user.email)
                if not user_domain or domain_filter.lower() != user_domain.lower():
                    continue
            
            filtered_users.append(user)
        
        return filtered_users
    
    def _extract_email_domain(self, email: Optional[str]) -> Optional[str]:
        """Extract domain from email address"""
        if not email or "@" not in email:
            return None
        return email.split("@")[1].lower()
    
    def _format_creation_month(self, created_at: Optional[datetime]) -> Optional[str]:
        """Format creation date to month-year"""
        if not created_at:
            return None
        return created_at.strftime("%Y-%m")
    
    def _calculate_name_length(self, user: User) -> int:
        """Calculate total name length"""
        first_name = user.first_name or ""
        last_name = user.last_name or ""
        return len(first_name) + len(last_name)
    
    def _identify_potential_issues(self, users: List[User]) -> List[str]:
        """Identify potential issues with users"""
        issues = []
        
        # Check for users without names
        users_without_names = sum(
            1 for user in users
            if not user.first_name or not user.first_name.strip() or
               not user.last_name or not user.last_name.strip()
        )
        
        if users_without_names > 0:
            issues.append(f"{users_without_names} users have incomplete names")
        
        # Check for users with very short names
        users_with_short_names = sum(
            1 for user in users
            if self._calculate_name_length(user) < 4
        )
        
        if users_with_short_names > 0:
            issues.append(f"{users_with_short_names} users have very short names")
        
        # Check for inactive users
        inactive_users = sum(1 for user in users if not user.enabled)
        
        if inactive_users > len(users) * 0.1:  # More than 10% inactive
            percentage = (inactive_users / len(users)) * 100
            issues.append(f"High number of inactive users: {inactive_users} ({percentage:.1f}%)")
        
        return issues


# Example usage and testing
def main():
    """Example usage of the UserDataProcessor"""
    processor = UserDataProcessor()
    
    # Create sample users
    users = [
        User(
            id=1,
            email="john.doe@example.com",
            first_name="John",
            last_name="Doe",
            role=Role.USER,
            enabled=True,
            created_at=datetime.now() - timedelta(days=10)
        ),
        User(
            id=2,
            email="jane.smith@company.com",
            first_name="Jane",
            last_name="Smith",
            role=Role.ADMIN,
            enabled=True,
            created_at=datetime.now() - timedelta(days=5)
        ),
        User(
            id=3,
            email="bob@test.org",
            first_name="Bob",
            last_name="",
            role=Role.USER,
            enabled=False,
            created_at=datetime.now() - timedelta(days=40)
        )
    ]
    
    # Process user data
    result = processor.process_user_data(users)
    
    # Print results
    print(f"Total users: {result.total_users}")
    print(f"Active users: {result.active_users}")
    print(f"Role distribution: {result.role_distribution}")
    print(f"Top email domains: {result.top_email_domains}")
    print(f"Potential issues: {result.potential_issues}")


if __name__ == "__main__":
    main() 