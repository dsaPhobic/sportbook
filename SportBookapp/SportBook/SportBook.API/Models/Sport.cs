namespace SportBook.API.Models
{
    public class Sport
    {
        public Guid SportId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? IconUrl { get; set; }

        public List<CourtSport>? CourtSports { get; set; }
    }
}
