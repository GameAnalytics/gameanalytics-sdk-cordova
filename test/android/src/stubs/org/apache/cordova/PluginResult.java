package org.apache.cordova;

/** Test stub of PluginResult: records the status and the message type and value. */
public class PluginResult {
    public enum Status { NO_RESULT, OK, CLASS_NOT_FOUND_EXCEPTION, ILLEGAL_ACCESS_EXCEPTION,
        INSTANTIATION_EXCEPTION, MALFORMED_URL_EXCEPTION, IO_EXCEPTION, INVALID_ACTION,
        JSON_EXCEPTION, ERROR }

    private final Status status;
    private final Object message;

    public PluginResult(Status status) { this.status = status; this.message = null; }
    public PluginResult(Status status, String message) { this.status = status; this.message = message; }
    public PluginResult(Status status, int message) { this.status = status; this.message = message; }
    public PluginResult(Status status, float message) { this.status = status; this.message = message; }
    public PluginResult(Status status, boolean message) { this.status = status; this.message = message; }

    public Status getStatus() { return status; }
    /** The message with its Java type preserved (String, Boolean, Integer, Float or null). */
    public Object getMessageObject() { return message; }
}
