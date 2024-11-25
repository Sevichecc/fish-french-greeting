# Global kaomoji array
set -g fish_greeting_kaomojis \
    "ヾ(•ω•\`)o" \
    "٩(◕‿◕｡)۶" \
    "＿φ(°-°=)" \
    "⊂((・▽・))⊃" \
    "(｡･ω･｡)" \
    "=^._.^= ∫" \
    "ᕙ(\`▽\`)ᕗ" \
    "ʕ•ᴥ•ʔ" \
    "ʕ￫ᴥ￩ʔ" \
    "ʕ •`ᴥ•´ʔ" \
    "ʕ≧ᴥ≦ʔ" \
    "ʕ •ᴥ•ʔゝ☆" \
    "ʕ •ᴥ•ʔ" \
    "ʕ≧ᴥ≦ʔ" \
    "ʕ´•ᴥ•`ʔ" \
    "ʕ•́ᴥ•̀ʔっ" \
    "ʕ ꈍᴥꈍʔ" \
    "˙ᴥ˙" \
    "ʕ◉ᴥ◉ʔ" \
    "ʢᵕᴗᵕʡ"

function fish_greeting
    # Check if curl is installed
    if not command -v curl >/dev/null
        set_color red
        printf "Error: curl is not installed. Please install curl first.\n"
        set_color normal
        return 1
    end

    # Cache file path
    set -l cache_file "$HOME/.cache/fish_greeting_cache.xml"
    
    # Create cache directory if it doesn't exist
    if not test -d (dirname $cache_file)
        mkdir -p (dirname $cache_file)
    end

    set -l xml_data ""
    set -l should_fetch false
    set -l today (date "+%Y%m%d")

    # Check if cache exists and is from today
    if test -f $cache_file
        set -l cache_date (date -r $cache_file "+%Y%m%d")
        
        if test $cache_date = $today
            # Cache is from today, use it
            set xml_data (cat $cache_file)
        else
            # Cache is old, need to fetch
            set should_fetch true
        end
    else
        # No cache exists, need to fetch
        set should_fetch true
    end

    # Fetch new data if needed
    if test $should_fetch = true
        # Use Transparent Language API for French
        set -l transparent_url "https://wotd.transparent.com/rss/fr-widget.xml"
        set xml_data (curl -s -m 5 "$transparent_url" 2>/dev/null)
        
        # Save to cache if fetch was successful
        if test $status -eq 0
            printf "%s" $xml_data > $cache_file
        end
    end
    
    # Process the XML data (whether from cache or fresh fetch)
    if test -n "$xml_data"
        # Parse XML response
        set -l word (echo $xml_data | string match -r '<word>([^<]+)</word>' | string replace -r '^.*>([^<]+)<.*$' '$1' | head -n 1)
        set -l translation (echo $xml_data | string match -r '<translation>([^<]+)</translation>' | string replace -r '^.*>([^<]+)<.*$' '$1' | head -n 1)
        set -l example_fr (echo $xml_data | string match -r '<fnphrase>([^<]+)</fnphrase>' | string replace -r '^.*>([^<]+)<.*$' '$1' | head -n 1)
        set -l example_en (echo $xml_data | string match -r '<enphrase>([^<]+)</enphrase>' | string replace -r '^.*>([^<]+)<.*$' '$1' | head -n 1)
        
        if test -n "$word" -a -n "$translation"
            # Display French word of the day
            set_color brmagenta
            printf "✧ Today's French Word: %s ✧\n" $word
            set_color normal
            printf "Meaning: %s\n" $translation
            if test -n "$example_fr" -a -n "$example_en"
                set_color yellow
                printf "Example: %s\n" $example_fr
                printf "         (%s)\n" $example_en
            end
            set_color brgreen
            printf "Bonne programmation et bonne pêche, %s!\n" $USER
            set_color brblack
            set -l random_kaomoji (random choice $fish_greeting_kaomojis)
            printf "%s %s\n" $random_kaomoji (LC_TIME=fr_FR.UTF-8 date "+%A %d %B %Y %H:%M:%S")
            set_color normal
            return
        end
    end
    
    # Fallback greeting if no data available
    set_color yellow
    printf "Unable to get word of the day, showing default greeting\n"
    set_color normal
    printf "Welcome to Fish Shell!\n"
    set_color brblack
    set -l random_kaomoji (random choice $fish_greeting_kaomojis)
    printf "%s %s\n" $random_kaomoji (date)
    set_color normal
end