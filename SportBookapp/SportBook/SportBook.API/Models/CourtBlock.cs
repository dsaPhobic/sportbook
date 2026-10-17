namespace SportBook.API.Models
{
    public class CourtBlock
    {
        public Guid CourtBlockId { get; set; }
        public Guid CourtId { get; set; }
        public Guid BlockedByUserId { get; set; }
        public DateTime BlockStart { get; set; }
        public DateTime BlockEnd { get; set; }
        public string? Reason { get; set; }

        public Court? Court { get; set; }
        public User? BlockedByUser { get; set; }
    }
}
