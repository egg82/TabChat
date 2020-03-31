package me.egg82.tchat.extended;

import com.google.common.collect.ImmutableList;
import java.util.List;
import java.util.Locale;
import me.egg82.tchat.storage.Storage;

public class CachedConfigValues {
    private CachedConfigValues() {}

    private ImmutableList<Storage> storage = ImmutableList.of();
    public ImmutableList<Storage> getStorage() { return storage; }

    private ImmutableList<Messaging> messaging = ImmutableList.of();
    public ImmutableList<Messaging> getMessaging() { return messaging; }

    private boolean allowColors = true;
    public boolean getAllowColors() { return allowColors; }

    private boolean debug = false;
    public boolean getDebug() { return debug; }

    private Locale language = Locale.US;
    public Locale getLanguage() { return language; }

    public static CachedConfigValues.Builder builder() { return new CachedConfigValues.Builder(); }

    public static class Builder {
        private final CachedConfigValues values = new CachedConfigValues();

        private Builder() { }

        public CachedConfigValues.Builder storage(List<Storage> value) {
            values.storage = ImmutableList.copyOf(value);
            return this;
        }

        public CachedConfigValues.Builder messaging(List<Messaging> value) {
            values.messaging = ImmutableList.copyOf(value);
            return this;
        }

        public CachedConfigValues.Builder allowColors(boolean value) {
            values.allowColors = value;
            return this;
        }

        public CachedConfigValues.Builder debug(boolean value) {
            values.debug = value;
            return this;
        }

        public CachedConfigValues.Builder language(Locale value) {
            values.language = value;
            return this;
        }

        public CachedConfigValues build() { return values; }
    }
}
