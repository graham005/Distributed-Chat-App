// This simulates multiple servers running on different port. Each server should accept clients independently.

namespace ChatApp_API.Services
{
    public class ServerManager
    {
        private List<ServerNode> _servers = new List<ServerNode>();
        private int _currentServerIndex = 0;

        public void StartServers()
        {
            _servers.Add(new ServerNode(8000));
            _servers.Add(new ServerNode(8001));

            foreach (var server in _servers)
            {
                Task.Run(() => server.Start());
            }
        }

        public ServerNode GetNextServer()
        {
            lock (this)
            {
                _currentServerIndex = (_currentServerIndex + 1) % _servers.Count;
                return _servers[_currentServerIndex];
            }
        }
    }
}
