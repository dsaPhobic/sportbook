namespace SportBook.API.Models
{
    public class CourtSport
    {
        public Guid Id { get; set; }
        public Guid CourtId { get; set; }
        public Guid SportId { get; set; }
        public decimal PricePerHour { get; set; }
        public bool IsPrimarySport { get; set; }

        public Court? Court { get; set; }
        public Sport? Sport { get; set; }
    }
}
