-- Insert SQL Rules Here 

-- Delete lines from Mongolia that mention Genghis on Mongolia
DELETE FROM LocalizedText Where Tag = "TXT_KEY_LEADER_GENGHIS_FIRSTGREETING_2";
DELETE FROM LocalizedText Where Tag = "TXT_KEY_LEADER_GENGHIS_FIRSTGREETING_3";

-- Add scenario specific entries.
INSERT OR REPLACE INTO LocalizedText (Language, Tag, Gender, Plurality, Text) Select Language, Replace(Tag, 'TXT_KEY_KOREA_SCENARIO_', 'TXT_KEY_'), Gender, Plurality, Text from LocalizedText where Tag LIKE 'TXT_KEY_KOREA_SCENARIO_%';
