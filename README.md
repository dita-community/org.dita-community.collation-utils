# org.dita-community.collation-utils
Collation (grouping and sorting) utilities, including dictionary-based Simplified Chinese sorting.

This project is the start of more complete support for locale-specific collation
for use with the DITA Open Toolkit or other XSLT processors.

The Simplified Chinese sorting support is based on the CC-CEDICT open-source dictionary,
available here:

http://www.mdbg.net/chindict/chindict.php?page=cedict

See that page for licensing details, but per that Web site, the data may be used for
commercial and non-commercial purposes as long as attribution is provided.

## Status

As of 17 Sept 2016 this is a simple proof of concept to demonstrate that the
CC-CEDICT data is sufficient to do reasonably-correct Simplified Chinese 
sorting.

NOTE: The test data set has been omitted pending permission to include it. The
expected format of the glossary.ditamap is a DITA map with a topichead with the 
navigation title "Glossary" and child topicrefs to glossentry topics.

The XSLT module xsl/collation-utils.xsl implements functions to get DITA-specific
sort keys for elements and, when the language is "zh-CN", uses the CC-CEBIT dictionary
to look up Pin-Yin transliterations for the base Chinese sort key.

For other languages the input sort key is simply returned. Support for other languages
could be added as needed, but for most other languages the built-in Unicode code point
collation should be appropriate.

It would also be possible to generalize the ICU4J-based collation support that's in the
DITA Open Toolkit PDF2 transform to handle other languages more completely. That code
uses configuration files to define the collation and grouping rules for a large number
of languages and is sufficient for all languages except Simplified Chinese, which requires
a dictionary-based solution.

Antenna House (http://www.antennahouse.com) provides a commercial Simplified Chinese
library for use with XSLT generally and with the DITA Open Toolkit. It provides complete
grouping and supporting for most languages, including Asian languages.
