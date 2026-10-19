namespace SportBook.API.DTOs
{
    public class AddEquipmentDTO
    {
        public Guid ReservationId { get; set; }
        public Guid EquipmentId { get; set; }
        public int Quantity { get; set; }
    }
}
