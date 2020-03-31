package me.egg82.tchat.core;

import java.util.Objects;
import java.util.UUID;

public class ChatResult {
    private final long id;
    private final UUID serverID;
    private final String serverName;
    private final UUID playerID;
    private final String playerName;
    private final String playerDisplayName;
    private final long channelID;
    private final String channelName;
    private final long worldID;
    private final String worldName;
    private final double locationX;
    private final double locationY;
    private final double locationZ;
    private final String message;
    private final long dateTime;

    private final int hc;

    public ChatResult(long id, UUID serverID, String serverName, UUID playerID, String playerName, String playerDisplayName, long channelID, String channelName, long worldID, String worldName, String message, long dateTime) {
        this(id, serverID, serverName, playerID, playerName, playerDisplayName, channelID, channelName, worldID, worldName, Double.NaN, Double.NaN, Double.NaN, message, dateTime);
    }

    public ChatResult(long id, UUID serverID, String serverName, UUID playerID, String playerName, String playerDisplayName, long channelID, String channelName, long worldID, String worldName, double locationX, double locationY, double locationZ, String message, long dateTime) {
        this.id = id;
        this.serverID = serverID;
        this.serverName = serverName;
        this.playerID = playerID;
        this.playerName = playerName;
        this.playerDisplayName = playerDisplayName;
        this.channelID = channelID;
        this.channelName = channelName;
        this.worldID = worldID;
        this.worldName = worldName;
        this.locationX = locationX;
        this.locationY = locationY;
        this.locationZ = locationZ;
        this.message = message;
        this.dateTime = dateTime;

        hc = Objects.hash(id);
    }

    public long getID() { return id; }

    public UUID getServerID() { return serverID; }

    public String getServerName() { return serverName; }

    public UUID getPlayerID() { return playerID; }

    public String getPlayerName() { return playerName; }

    public String getPlayerDisplayName() { return playerDisplayName; }

    public long getChannelID() { return channelID; }

    public String getChannelName() { return channelName; }

    public long getWorldID() { return worldID; }

    public String getWorldName() { return worldName; }

    public double getLocationX() { return locationX; }

    public double getLocationY() { return locationY; }

    public double getLocationZ() { return locationZ; }

    public String getMessage() { return message; }

    public long getDateTime() { return dateTime; }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ChatResult)) return false;
        ChatResult that = (ChatResult) o;
        return id == that.id;
    }

    public int hashCode() { return hc; }
}
