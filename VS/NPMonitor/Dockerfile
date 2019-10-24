FROM mcr.microsoft.com/dotnet/core/runtime:3.0-buster-slim AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/core/sdk:3.0-buster-slim AS build
WORKDIR /src
COPY ["NPMonitor/NPMonitor.csproj", "NPMonitor/"]
RUN dotnet restore "NPMonitor/NPMonitor.csproj"
COPY . .
WORKDIR "/src/NPMonitor"
RUN dotnet build "NPMonitor.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "NPMonitor.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "NPMonitor.dll"]