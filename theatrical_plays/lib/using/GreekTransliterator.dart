class GreekTransliterator {
  static final Map<String, String> _map = {
    'α': 'a',
    'ά': 'a',
    'β': 'v',
    'γ': 'g',
    'δ': 'd',
    'ε': 'e',
    'έ': 'e',
    'ζ': 'z',
    'η': 'i',
    'ή': 'i',
    'θ': 'th',
    'ι': 'i',
    'ί': 'i',
    'ϊ': 'i',
    'ΐ': 'i',
    'κ': 'k',
    'λ': 'l',
    'μ': 'm',
    'ν': 'n',
    'ξ': 'x',
    'ο': 'o',
    'ό': 'o',
    'π': 'p',
    'ρ': 'r',
    'σ': 's',
    'ς': 's',
    'τ': 't',
    'υ': 'y',
    'ύ': 'y',
    'ϋ': 'y',
    'ΰ': 'y',
    'φ': 'f',
    'χ': 'ch',
    'ψ': 'ps',
    'ω': 'o',
    'ώ': 'o'
  };

  static String transliterate(String input) {
    return input
        .toLowerCase()
        .split('')
        .map((char) => _map[char] ?? char)
        .join();
  }
}
