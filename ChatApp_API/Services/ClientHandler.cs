// Handle server failover. Incase one server goes down, client is conected to another server.

namespace ChatApp_API.Services
{
    public class ClientHandler
    {
        private ServerManager _serverManager;

        public ClientHandler(ServerManager serverManager)
        {
            _serverManager = serverManager;
        }

        public async Task ConnectToServer()
        {
            ServerNode server = _serverManager.GetNextServer();

            try
            {
                await server.Start();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error connecting to server: {ex.Message}");
            }
        }
    }
}
