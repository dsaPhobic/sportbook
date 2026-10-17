using Microsoft.EntityFrameworkCore;
using SportBook.API.Models;

namespace SportBook.API.Data
{
    public class SportBookContext : DbContext
    {
        public SportBookContext(DbContextOptions<SportBookContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<SportsFacility> SportsFacilities { get; set; }
        public DbSet<Sport> Sports { get; set; }
        public DbSet<Court> Courts { get; set; }
        public DbSet<CourtSport> CourtSports { get; set; }
        public DbSet<WorkingHours> WorkingHours { get; set; }
        public DbSet<CourtBlock> CourtBlocks { get; set; }
        public DbSet<TimeSlot> TimeSlots { get; set; }
        public DbSet<Reservation> Reservations { get; set; }
        public DbSet<QRCode> QRCodes { get; set; }
        public DbSet<Equipment> Equipment { get; set; }
        public DbSet<ReservationEquipment> ReservationEquipment { get; set; }
        public DbSet<Review> Reviews { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>().ToTable("Users").HasKey(u => u.UserId);
            modelBuilder.Entity<Role>().ToTable("Roles").HasKey(r => r.RoleId);
            modelBuilder.Entity<UserRole>().ToTable("UserRoles").HasKey(ur => ur.Id);
            modelBuilder.Entity<SportsFacility>().ToTable("SportsFacilities").HasKey(sf => sf.FacilityId);
            modelBuilder.Entity<Sport>().ToTable("Sports").HasKey(s => s.SportId);
            modelBuilder.Entity<Court>().ToTable("Courts").HasKey(c => c.CourtId);
            modelBuilder.Entity<CourtSport>().ToTable("CourtSports").HasKey(cs => cs.Id);
            modelBuilder.Entity<WorkingHours>().ToTable("WorkingHours").HasKey(wh => wh.WorkingHoursId);
            modelBuilder.Entity<CourtBlock>().ToTable("CourtBlocks").HasKey(cb => cb.CourtBlockId);
            modelBuilder.Entity<TimeSlot>().ToTable("TimeSlots").HasKey(ts => ts.TimeSlotId);
            modelBuilder.Entity<Reservation>().ToTable("Reservations").HasKey(r => r.ReservationId);
            modelBuilder.Entity<QRCode>().ToTable("QRCodes").HasKey(q => q.QRCodeId);
            modelBuilder.Entity<Equipment>().ToTable("Equipment").HasKey(e => e.EquipmentId);
            modelBuilder.Entity<ReservationEquipment>().ToTable("ReservationEquipment").HasKey(re => re.Id);
            modelBuilder.Entity<Review>().ToTable("Reviews").HasKey(r => r.ReviewId);

            modelBuilder.Entity<CourtSport>().Property(cs => cs.PricePerHour).HasPrecision(18, 2);
            modelBuilder.Entity<Equipment>().Property(e => e.RentalPrice).HasPrecision(18, 2);
            modelBuilder.Entity<Reservation>().Property(r => r.TotalPrice).HasPrecision(18, 2);
            modelBuilder.Entity<ReservationEquipment>().Property(re => re.TotalPrice).HasPrecision(18, 2);
            modelBuilder.Entity<TimeSlot>().Property(ts => ts.Price).HasPrecision(18, 2);

            // One-to-one: QRCode <-> Reservation
            modelBuilder.Entity<QRCode>()
                .HasOne(q => q.Reservation)
                .WithOne(r => r.QRCode)
                .HasForeignKey<QRCode>(q => q.ReservationId);

            // One-to-one: Review <-> Reservation
            modelBuilder.Entity<Review>()
                .HasOne(r => r.Reservation)
                .WithOne(res => res.Review)
                .HasForeignKey<Review>(r => r.ReservationId);

            // One-to-one: Reservation <-> TimeSlot
            modelBuilder.Entity<Reservation>()
                .HasOne(r => r.TimeSlot)
                .WithOne(ts => ts.Reservation)
                .HasForeignKey<Reservation>(r => r.TimeSlotId);

            // Many-to-one: UserRole -> User
            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.User)
                .WithMany(u => u.UserRoles)
                .HasForeignKey(ur => ur.UserId);

            // Many-to-one: UserRole -> Role
            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.Role)
                .WithMany()
                .HasForeignKey(ur => ur.RoleId);

            // Many-to-one: CourtSport -> Court
            modelBuilder.Entity<CourtSport>()
                .HasOne(cs => cs.Court)
                .WithMany(c => c.CourtSports)
                .HasForeignKey(cs => cs.CourtId);

            // Many-to-one: CourtSport -> Sport
            modelBuilder.Entity<CourtSport>()
                .HasOne(cs => cs.Sport)
                .WithMany(s => s.CourtSports)
                .HasForeignKey(cs => cs.SportId);

            // Many-to-one: Court -> SportsFacility
            modelBuilder.Entity<Court>()
                .HasOne(c => c.SportsFacility)
                .WithMany(sf => sf.Courts)
                .HasForeignKey(c => c.FacilityId);

            // Many-to-one: WorkingHours -> Court
            modelBuilder.Entity<WorkingHours>()
                .HasOne(wh => wh.Court)
                .WithMany(c => c.WorkingHours)
                .HasForeignKey(wh => wh.CourtId);

            // Many-to-one: TimeSlot -> Court
            modelBuilder.Entity<TimeSlot>()
                .HasOne(ts => ts.Court)
                .WithMany(c => c.TimeSlots)
                .HasForeignKey(ts => ts.CourtId);

            // Many-to-one: TimeSlot -> Sport
            modelBuilder.Entity<TimeSlot>()
                .HasOne(ts => ts.Sport)
                .WithMany()
                .HasForeignKey(ts => ts.SportId);

            // Many-to-one: Reservation -> User
            modelBuilder.Entity<Reservation>()
                .HasOne(r => r.User)
                .WithMany()
                .HasForeignKey(r => r.UserId);

            // Many-to-one: Equipment -> SportsFacility
            modelBuilder.Entity<Equipment>()
                .HasOne(e => e.SportsFacility)
                .WithMany(sf => sf.Equipment)
                .HasForeignKey(e => e.FacilityId);

            // Many-to-one: ReservationEquipment -> Reservation
            modelBuilder.Entity<ReservationEquipment>()
                .HasOne(re => re.Reservation)
                .WithMany(r => r.ReservationEquipment)
                .HasForeignKey(re => re.ReservationId);

            // Many-to-one: ReservationEquipment -> Equipment
            modelBuilder.Entity<ReservationEquipment>()
                .HasOne(re => re.Equipment)
                .WithMany(e => e.ReservationEquipment)
                .HasForeignKey(re => re.EquipmentId)
                .OnDelete(DeleteBehavior.Restrict);

            // Many-to-one: CourtBlock -> Court
            modelBuilder.Entity<CourtBlock>()
                .HasOne(cb => cb.Court)
                .WithMany()
                .HasForeignKey(cb => cb.CourtId);

            // Many-to-one: CourtBlock -> User (BlockedByUser)
            modelBuilder.Entity<CourtBlock>()
                .HasOne(cb => cb.BlockedByUser)
                .WithMany()
                .HasForeignKey(cb => cb.BlockedByUserId);
        }
    }
}