using ChatApp_API.Models;

namespace ChatApp_API.Services
{
    public class UserService
    {
        private static List<User> _users = new List<User>();

        public bool Register(string username, string password)
        {
            if (_users.Any(u => u.Username == username)) return false; // If username exists
            _users.Add(new User  {Username = username, Password = password});
            return true;
        }

        public User Login(string username, string password)
        {
            var user = _users.FirstOrDefault(u => u.Username == username && u.Password == password);
            if (user == null)
            {
                throw new Exception("Invalid username or password");
            }
            return user;
        }
    }
}
// User Detail are temporarily stored in this class 