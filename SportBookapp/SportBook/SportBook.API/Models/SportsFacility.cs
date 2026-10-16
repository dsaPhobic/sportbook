namespace SportBook.API.Models
{
    public class SportsFacility
    {
        public Guid FacilityId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string? Phone { get; set; }
        public string? Email { get; set; }
        public bool IsActive { get; set; }

        public List<Court>? Courts { get; set; }
        public List<Equipment>? Equipment { get; set; }
    }
}
