package util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class VideoUtil {

    // Supports:
    // https://www.youtube.com/watch?v=ID
    // https://youtu.be/ID
    // https://www.youtube.com/embed/ID
    // https://www.youtube.com/shorts/ID
    // https://m.youtube.com/watch?v=ID
    private static final Pattern YOUTUBE_PATTERN = Pattern.compile(
            "(?:https?:\\/\\/)?(?:www\\.|m\\.)?(?:youtube\\.com\\/(?:watch\\?v=|embed\\/|v\\/|shorts\\/)|youtu\\.be\\/)([a-zA-Z0-9_-]{11})",
            Pattern.CASE_INSENSITIVE
    );

    /**
     * Converts any YouTube URL to an embeddable URL: https://www.youtube.com/embed/{VIDEO_ID}
     * Leaves other video URLs (MP4, Direct URLs) unchanged.
     */
    public static String toEmbedUrl(String rawUrl) {
        if (rawUrl == null || rawUrl.isBlank()) {
            return "";
        }
        String trimmed = rawUrl.trim();
        Matcher matcher = YOUTUBE_PATTERN.matcher(trimmed);
        if (matcher.find()) {
            String videoId = matcher.group(1);
            return "https://www.youtube.com/embed/" + videoId;
        }
        return trimmed;
    }

    /**
     * Checks if the given URL is an embeddable YouTube URL.
     */
    public static boolean isYouTube(String url) {
        if (url == null || url.isBlank()) {
            return false;
        }
        return url.contains("youtube.com/embed/") || YOUTUBE_PATTERN.matcher(url).find();
    }
}
