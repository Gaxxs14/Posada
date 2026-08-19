# Build stage (Flutter web is already pre-built in frontend/build/web)
FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build
WORKDIR /app

# Copy csproj and solution files
COPY Posada.sln* .
COPY src/Posada.Domain/*.csproj src/Posada.Domain/
COPY src/Posada.Application/*.csproj src/Posada.Application/
COPY src/Posada.Infrastructure/*.csproj src/Posada.Infrastructure/
COPY src/Posada.API/*.csproj src/Posada.API/

# Restore dependencies
RUN dotnet restore src/Posada.API/Posada.API.csproj

# Copy all source files
COPY . .

WORKDIR /app/src/Posada.API
RUN dotnet publish -c Release -o /out

# Copy Flutter Web build into the published output (wwwroot)
# The web files are in ../../frontend/build/web relative to /app/src/Posada.API
WORKDIR /app
RUN mkdir -p /out/wwwroot && cp -r frontend/build/web/. /out/wwwroot/ || true

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0-preview AS runtime
WORKDIR /app
COPY --from=build /out .

ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production
ENV DOTNET_HOSTBUILDER__RELOADCONFIGONCHANGE=false
ENV DOTNET_USE_POLLING_FILE_WATCHER=true

EXPOSE 8080

ENTRYPOINT ["dotnet", "Posada.API.dll"]
