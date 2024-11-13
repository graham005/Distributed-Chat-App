// Logging to persist chat messages in case of crashes 

namespace ChatApp_API.Services
{
    public class Logger
    {
        private static readonly object _logLock = new object();
        private readonly string _logFilePath = "chatlog.txt";

        public void LogMessage (string message)
        {
            lock (_logLock)
            {
                using (StreamWriter writer = new StreamWriter(_logFilePath, true))
                {
                    writer.WriteLine($"{DateTime.Now}: {message}");
                }
            }
        }
    }
}
