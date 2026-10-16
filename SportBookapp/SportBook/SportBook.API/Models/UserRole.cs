namespace SportBook.API.Models
{
    public class UserRole
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public Guid RoleId { get; set; }
        public DateTime AssignedDate { get; set; }

        public User? User { get; set; }
        public Role? Role { get; set; }
    }
}
