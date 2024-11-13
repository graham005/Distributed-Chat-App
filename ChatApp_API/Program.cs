using ChatApp_API.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddSingleton<UserService>();
builder.Services.AddSingleton<ServerManager>();
builder.Services.AddSingleton<Logger>();
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowNgrok",
        builder => builder.WithOrigins("https://<your-ngrok-id>.ngrok.io")
                          .AllowAnyMethod()
                          .AllowAnyHeader()
                          .AllowCredentials());
});


var app = builder.Build();

var serverManager = app.Services.GetRequiredService<ServerManager>();
serverManager.StartServers();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.UseCors("AllowNgrok");

app.Run();
