namespace SportBook.API.Models
{
    public class ReservationEquipment
    {
        public Guid Id { get; set; }
        public Guid ReservationId { get; set; }
        public Guid EquipmentId { get; set; }
        public int Quantity { get; set; }
        public decimal TotalPrice { get; set; }

        public Reservation? Reservation { get; set; }
        public Equipment? Equipment { get; set; }
    }
}
