# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build
WORKDIR /app

# Copy solution and csproj files
COPY *.sln .
COPY src/Posada.Domain/*.csproj src/Posada.Domain/
COPY src/Posada.Application/*.csproj src/Posada.Application/
COPY src/Posada.Infrastructure/*.csproj src/Posada.Infrastructure/
COPY src/Posada.API/*.csproj src/Posada.API/

# Restore dependencies
RUN dotnet restore

# Copy all source files and build
COPY . .
WORKDIR /app/src/Posada.API
RUN dotnet publish -c Release -o /out

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0-preview AS runtime
WORKDIR /app
COPY --from=build /out .

ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

EXPOSE 8080

ENTRYPOINT ["dotnet", "Posada.API.dll"]
