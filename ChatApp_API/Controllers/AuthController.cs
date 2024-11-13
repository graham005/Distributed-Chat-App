using ChatApp_API.Models;
using ChatApp_API.Services;
using Microsoft.AspNetCore.Mvc;

namespace ChatApp_API.Controllers
{
    [Route("api/auth")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly UserService _userService;

        public AuthController(UserService userService)
        {
            _userService = userService;
        }

        [HttpPost("register")]
        public IActionResult Register([FromBody] User user)
        {
            if (_userService.Register(user.Username, user.Password)) 
                return Ok("User registered successfully.");
            return BadRequest("Username already exists.");
        }

        [HttpPost("login")]
        public IActionResult Login([FromBody] User user)
        {
            var loggedInUser = _userService.Login(user.Username, user.Password);
            if (loggedInUser != null)
                return Ok("Login succesful.");
            return Unauthorized("Invalid username or password.");
        }
    }
}
