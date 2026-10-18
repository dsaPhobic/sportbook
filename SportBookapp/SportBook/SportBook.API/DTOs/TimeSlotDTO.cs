namespace SportBook.API.DTOs
{
    public class GenerateTimeSlotsDTO
    {
        public Guid CourtId { get; set; }
        public DateOnly Date { get; set; }
    }
}
