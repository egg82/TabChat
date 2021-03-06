package me.egg82.tchat;

import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicLong;
import me.egg82.tchat.extended.CachedConfigValues;
import me.egg82.tchat.storage.Storage;
import me.egg82.tchat.storage.StorageException;
import me.egg82.tchat.utils.ConfigUtil;
import ninja.egg82.service.ServiceLocator;
import ninja.egg82.service.ServiceNotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TabChatAPI {
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private static final TabChatAPI api = new TabChatAPI();

    private final AtomicLong numSentMessages = new AtomicLong(0L);

    private TabChatAPI() { }

    public static TabChatAPI getInstance() { return api; }

    public void sendChat(UUID playerID, long channelID, String worldName, String message) throws APIException {
        if (playerID == null) {
            throw new APIException(false, "playerID cannot be null.");
        }
        if (worldName == null) {
            throw new APIException(false, "worldName cannot be null.");
        }
        if (message == null) {
            throw new APIException(false, "message cannot be null.");
        }

        // TODO: Finish this
    }

    public void sendChat(UUID playerID, long channelID, String worldName, double playerX, double playerY, double playerZ, String message) throws APIException {
        if (playerID == null) {
            throw new APIException(false, "playerID cannot be null.");
        }
        if (worldName == null) {
            throw new APIException(false, "worldName cannot be null.");
        }
        if (message == null) {
            throw new APIException(false, "message cannot be null.");
        }

        Optional<CachedConfigValues> cachedConfig = ConfigUtil.getCachedConfig();
        if (!cachedConfig.isPresent()) {
            throw new APIException(false, "Could not get cached config.");
        }

        StorageMessagingHandler handler;
        try {
            handler = ServiceLocator.get(StorageMessagingHandler.class);
        } catch (InstantiationException | IllegalAccessException | ServiceNotFoundException ex) {
            throw new APIException(false, "Could not get handler service.");
        }

        PostChatResult postResult = null;
        Storage postedStorage = null;
        boolean canRecover = false;
        for (Storage s : cachedConfig.get().getStorage()) {
            try {
                postResult = s.post(playerID, level, message);
                postedStorage = s;
                break;
            } catch (StorageException ex) {
                logger.error("[Recoverable: " + ex.isAutomaticallyRecoverable() + "] " + ex.getMessage(), ex);
                if (ex.isAutomaticallyRecoverable()) {
                    canRecover = true;
                }
            }
        }
        if (postResult == null) {
            throw new APIException(!canRecover, "Could not put chat in storage.");
        }

        handler.cachePost(postResult.getID());
        for (Storage s : cachedConfig.get().getStorage()) {
            try {
                if (s == postedStorage) {
                    continue;
                }
                s.postRaw(
                        postResult.getID(),
                        postResult.getLongServerID(),
                        postResult.getLongPlayerID(),
                        postResult.getLevel(),
                        postResult.getMessage(),
                        postResult.getDate()
                );
            } catch (StorageException ex) {
                logger.error("[Recoverable: " + ex.isAutomaticallyRecoverable() + "] " + ex.getMessage(), ex);
            }
        }

        canRecover = false;
        if (cachedConfig.get().getMessaging().size() > 0) {
            boolean handled = false;
            UUID messageID = UUID.randomUUID();
            handler.cacheMessage(messageID);
            for (Messaging m : cachedConfig.get().getMessaging()) {
                try {
                    m.sendPost(
                            messageID,
                            postResult.getID(),
                            postResult.getLongServerID(),
                            postResult.getServerID(),
                            postResult.getServerName(),
                            postResult.getLongPlayerID(),
                            postResult.getPlayerID(),
                            postResult.getLevel(),
                            postResult.getLevelName(),
                            postResult.getMessage(),
                            postResult.getDate()
                    );
                    handled = true;
                } catch (MessagingException ex) {
                    logger.error("[Recoverable: " + ex.isAutomaticallyRecoverable() + "] " + ex.getMessage(), ex);
                    if (ex.isAutomaticallyRecoverable()) {
                        canRecover = true;
                    }
                }
            }

            if (!handled) {
                throw new APIException(!canRecover, "Could not send chat through messaging.");
            }
        }

        numSentMessages.getAndIncrement();
        handler.postMessage(postResult.toChatResult());
    }
}
