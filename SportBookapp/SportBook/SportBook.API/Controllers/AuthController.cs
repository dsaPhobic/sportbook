using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using SportBook.API.Data;
using SportBook.API.DTOs;
using SportBook.API.Models;

namespace SportBook.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly SportBookContext _context;
        private readonly IConfiguration _configuration;

        public AuthController(SportBookContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDTO dto)
        {
            if (await _context.Users.AnyAsync(k => k.Email == dto.Email))
                return BadRequest("A user with this email already exists.");

            var passwordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password);

            var user = new User
            {
                UserId = Guid.NewGuid(),
                FirstName = dto.FirstName,
                LastName = dto.LastName,
                Email = dto.Email,
                PasswordHash = passwordHash,
                Phone = dto.Phone,
                RegistrationDate = DateTime.Now,
                IsActive = true
            };

            _context.Users.Add(user);

            var clientRole = await _context.Roles.FirstOrDefaultAsync(u => u.Name == "client");
            if (clientRole != null)
            {
                _context.UserRoles.Add(new UserRole
                {
                    Id = Guid.NewGuid(),
                    UserId = user.UserId,
                    RoleId = clientRole.RoleId,
                    AssignedDate = DateTime.Now
                });
            }

            await _context.SaveChangesAsync();

            var token = GenerateToken(user, "client");

            return Ok(new AuthResponseDTO
            {
                Token = token,
                UserId = user.UserId.ToString(),
                FirstName = user.FirstName,
                LastName = user.LastName,
                Email = user.Email,
                Role = "client"
            });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDTO dto)
        {
            var user = await _context.Users
                .Include(k => k.UserRoles!)
                    .ThenInclude(ku => ku.Role)
                .FirstOrDefaultAsync(k => k.Email == dto.Email);

            if (user == null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
                return Unauthorized("Incorrect email or password.");

            var role = user.UserRoles?.FirstOrDefault()?.Role?.Name ?? "client";

            var token = GenerateToken(user, role);

            return Ok(new AuthResponseDTO
            {
                Token = token,
                UserId = user.UserId.ToString(),
                FirstName = user.FirstName,
                LastName = user.LastName,
                Email = user.Email,
                Role = role
            });
        }

        private string GenerateToken(User user, string role)
        {
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(
                _configuration["Jwt:Key"] ?? "DefaultSecretKey12345678901234567890"));

            var claims = new[]
            {
                new Claim("UserId", user.UserId.ToString()),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Role, role)
            };

            var token = new JwtSecurityToken(
                claims: claims,
                expires: DateTime.Now.AddDays(7),
                signingCredentials: new SigningCredentials(key, SecurityAlgorithms.HmacSha256)
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
