// Manages each server node and communicate via TCP socket
using System.Net;
using System.Net.WebSockets;
using System.Text;

namespace ChatApp_API.Services
{
    public class ServerNode
    {
        private readonly int _port;
        private HttpListener _listener;
        private List<WebSocket> _clients = new List<WebSocket>();
        private Dictionary<string, WebSocket> _clientMapping = 
            new Dictionary<string, WebSocket>(); // Username to websocket mapping
        private static readonly object _lock = new object(); // For thread safety
        private UserService _userService = new UserService(); // Initialize the user service

        public ServerNode(int port)
        {
            _port = port;
        }

        public async Task Start()
        {
            try
            { 
                _listener = new HttpListener();
                _listener.Prefixes.Add($"http://*:{_port}/");
                _listener.Start();
                Console.WriteLine($"Server listening on port {_port}.");

                await AcceptClientsAsync();

            }
            catch ( Exception ex )
            {
                Console.WriteLine($"An error occured: {ex.Message}");
            }
           
        }

        private async Task AcceptClientsAsync()
        {
            while (true)
            {
                HttpListenerContext context = await _listener.GetContextAsync();
                if (context.Request.IsWebSocketRequest)
                {
                    HttpListenerWebSocketContext webSocketContext = await context.AcceptWebSocketAsync(null);
                    WebSocket webSocket = webSocketContext.WebSocket;

                    lock (_lock)
                    {
                        _clients.Add(webSocket);
                    }
                    Console.WriteLine("Client connected");
                    _ = HandleClientAsync(webSocket);
                }
                else
                {
                    context.Response.StatusCode = 400;
                    context.Response.Close();
                }
            }
        }

        private async Task HandleClientAsync(WebSocket client)
        {
            byte[] buffer = new byte[1024];
            string username = null ;

            while (client.State == WebSocketState.Open)
            {
                var result = await client.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);
                if(result.MessageType == WebSocketMessageType.Close)
                {
                    await client.CloseAsync(WebSocketCloseStatus.NormalClosure, "Closing", CancellationToken.None);
                    break;
                }

                string message = Encoding.UTF8.GetString(buffer, 0, result.Count);

                if (message.StartsWith("REGISTER"))
                {
                    Console.WriteLine($"Recieved message: {message}");
                    string[] credentials = message.Split(':');
                    if (credentials.Length == 3)
                    {
                        username = credentials[1];
                        string password = credentials[2];

                        try
                        {
                            _userService.Register(username, password);
                            lock (_lock)
                            {
                                _clientMapping[username] = client;
                            }
                            SendMessage(client, "SUCCESSR");
                            BroadcastMessage($"{username} has joined the chat.");
                            BroadcastUserList();


                        }
                        catch (Exception ex)
                        {
                            SendMessage(client, $"ERROR:{ex.Message}");
                        }
                    }
                    else if (credentials.Length > 3)
                    {
                        Console.WriteLine("The Credential length is greater than three");
                    }
                    else
                    {
                        Console.WriteLine("The Credential length is less than three");
                    }

                }

                // Handle login messages
                else if (message.StartsWith("LOGIN"))
                {
                    string[] credentials = message.Split(":");
                    if (credentials.Length == 3) // LOGIN:username:password
                    {
                        username = credentials[1];
                        string password = credentials[2];

                        lock (_lock)
                        {
                            if (_clientMapping.ContainsKey(username))
                            {
                                // Close the existing connection
                                var existingClient = _clientMapping[username];
                                if (existingClient.State == WebSocketState.Open)
                                {
                                    existingClient.CloseAsync(WebSocketCloseStatus.NormalClosure, "User logged in elsewhere", CancellationToken.None);
                                }
                            }
                        }

                        try
                        {
                            _userService.Login(username, password);
                            lock (_lock)
                            {
                                _clientMapping[username] = client;
                            }
                            SendMessage(client, "SUCCESSL");
                            BroadcastMessage($"{username} has joined the chat.");

                            BroadcastUserList();
                        }
                        catch (Exception ex)
                        {
                            SendMessage(client, $"ERROR:{ex.Message}");
                        }
                    }
                    else if (credentials.Length > 3)
                    {
                        Console.WriteLine("The Credential length is greater than three");
                    }
                    else
                    {
                        Console.WriteLine("The Credential length is less than three");
                    }
                }
                // Handle regular messages
                else if (message.StartsWith("MSG:"))
                {
                   
                    BroadcastMessage($"{username}:{message.Substring(4)}");
                }
                // Handle private messages
                else if (message.StartsWith("PRIVATE:"))
                {
                    string[] parts = message.Split(':');
                    Console.WriteLine(message);
                    string recipient = parts[2];
                    string privateMessage = parts[3];

                    if (username != null)
                    {
                        SendPrivateMessage(username, recipient, privateMessage);
                    }
                }
            }
            // Safe removal of client when they disconnect
            lock (_lock)
            {
                _clients.Remove(client);
                if (username != null) _clientMapping.Remove(username);
            }
            Console.WriteLine("Client disconnected.");
        }

        private void BroadcastMessage(string message)
        {
            byte[] data = Encoding.UTF8.GetBytes(message);
            lock (_lock)
            {
                // Retrieve network stream and sends message asynchronously
                foreach (var client in _clients)
                {
                   if(client.State == WebSocketState.Open)
                    {
                        _= client.SendAsync(new ArraySegment<byte>(data), WebSocketMessageType.Text, true, CancellationToken.None);
                    }
                }
            }
        }

        private void BroadcastUserList()
        {
            string userListMessage = "USERLIST:" + string.Join(",", _clientMapping.Keys);
            Console.WriteLine($"Broadcasting user list:{userListMessage}");
            BroadcastMessage(userListMessage);
        }

        private void SendPrivateMessage(string sender, string recipient, string message)
        {
            lock (_lock)
            {
                if (_clientMapping.TryGetValue(recipient, out WebSocket recipientClient) && recipientClient.State == WebSocketState.Open) // Checks if recipient exists
                {
                    string formattedMessage = $"{message}";
                    byte[] data = Encoding.UTF8.GetBytes(formattedMessage);
                    _ = recipientClient.SendAsync(new ArraySegment<byte>(data), WebSocketMessageType.Text, true, CancellationToken.None);
                }
            }
        }

        private async void SendMessage(WebSocket webSocket, string message)
        {
            byte[] data = Encoding.UTF8.GetBytes(message);
            await webSocket.SendAsync(new ArraySegment<byte>(data), WebSocketMessageType.Text, true, CancellationToken.None);
        }

        
    }
}
