
FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://*:8080

FROM mcr.microsoft.com/dotnet/sdk:5.0-buster-slim AS build
WORKDIR /src
COPY ["maxApi/maxApi.csproj", "maxApi/"]
RUN dotnet restore "maxApi/maxApi.csproj"
COPY . .
WORKDIR "/src/maxApi"
RUN dotnet build "maxApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "maxApi.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
LABEL io.k8s.display-name="rubic" \
      io.k8s.description="container description..." \
      io.openshift.expose-services="8080:http"

ENTRYPOINT ["dotnet", "maxApi.dll"]
