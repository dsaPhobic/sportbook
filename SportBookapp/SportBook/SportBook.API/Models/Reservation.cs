namespace SportBook.API.Models
{
    public class Reservation
    {
        public Guid ReservationId { get; set; }
        public Guid UserId { get; set; }
        public Guid TimeSlotId { get; set; }
        public DateTime ReservationDate { get; set; }
        public string Status { get; set; } = "active"; // "active" or "cancelled"
        public decimal TotalPrice { get; set; }
        public string PaymentStatus { get; set; } = "pending";
        public string? Note { get; set; }

        public User? User { get; set; }
        public TimeSlot? TimeSlot { get; set; }
        public QRCode? QRCode { get; set; }
        public List<ReservationEquipment>? ReservationEquipment { get; set; }
        public Review? Review { get; set; }
    }
}
