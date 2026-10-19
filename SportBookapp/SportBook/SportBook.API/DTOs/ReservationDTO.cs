namespace SportBook.API.DTOs
{
    public class CreateReservationDTO
    {
        public Guid UserId { get; set; }
        public Guid TimeSlotId { get; set; }
        public string? Note { get; set; }
    }
}
