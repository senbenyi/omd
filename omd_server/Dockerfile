FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY src/OmdServer/OmdServer.csproj src/OmdServer/
RUN dotnet restore src/OmdServer/OmdServer.csproj
COPY src/OmdServer/ src/OmdServer/
RUN dotnet publish src/OmdServer/OmdServer.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "OmdServer.dll"]
