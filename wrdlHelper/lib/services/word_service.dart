import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:wrdlhelper/bridge_generated/wordle_ffi.dart' as ffi;
import 'package:wrdlhelper/exceptions/service_exceptions.dart';
import 'package:wrdlhelper/exceptions/validation_exceptions.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

/// WordService for managing word lists and operations
///
/// Handles loading word lists from assets, filtering, and searching
/// following TDD principles.
class WordService {
  // Mock data completely removed - only real words from assets allowed
  //   // static const List<String> _realGuessWords = [
  //     'CRANE',
  //     'SLATE',
  //     'TRACE',
  //     'CRATE',
  //     'SLANT',
  //     'ADIEU',
  //     'AUDIO',
  //     'RAISE',
  //     'AROSE',
  //     'STARE',
  //     'BLADE',
  //     'GRADE',
  //     'SHADE',
  //     'TRADE',
  //     'SPADE',
  //     'BLAME',
  //     'FLAME',
  //     'FRAME',
  //     'GAMES',
  //     'NAMES',
  //     'HOMES',
  //     'COMES',
  //     'DONES',
  //     'BONES',
  //     'STONE',
  //     'PHONE',
  //     'ALONE',
  //     'SHONE',
  //     'THONE',
  //     'CLONE',
  //     'PRONE',
  //     'DRONE',
  //     'CRONE',
  //     'TRONE',
  //     'GRONE',
  //     'BRONE',
  //     'FRONE',
  //     'WRONE',
  //     'SRONE',
  //     'VRONE',
  //     'XRONE',
  //     'YRONE',
  //     'ZRONE',
  //     'ABONE',
  //     'CBONE',
  //     'DBONE',
  //     'EBONE',
  //     'FBONE',
  //     'GBONE',
  //     'HBONE',
  //     'IBONE',
  //     'JBONE',
  //     'KBONE',
  //     'LBONE',
  //     'MBONE',
  //     'NBONE',
  //     'OBONE',
  //     'PBONE',
  //     'QBONE',
  //     'RBONE',
  //     'SBONE',
  //     'TBONE',
  //     'UBONE',
  //     'VBONE',
  //     'WBONE',
  //     'XBONE',
  //     'YBONE',
  //     'ZBONE',
  //     'ACONE',
  //     'BCONE',
  //     'CCONE',
  //     'DCONE',
  //     'ECONE',
  //     'FCONE',
  //     'GCONE',
  //     'HCONE',
  //     'ICONE',
  //     'JCONE',
  //     'KCONE',
  //     'LCONE',
  //     'MCONE',
  //     'NCONE',
  //     'OCONE',
  //     'PCONE',
  //     'QCONE',
  //     'RCONE',
  //     'SCONE',
  //     'TCONE',
  //     'UCONE',
  //     'VCONE',
  //     'WCONE',
  //     'XCONE',
  //     'YCONE',
  //     'ZCONE',
  //     'ADONE',
  //     'BDONE',
  //     'CDONE',
  //     'DDONE',
  //     'EDONE',
  //     'FDONE',
  //     'GDONE',
  //     'HDONE',
  //     'IDONE',
  //     'JDONE',
  //     'KDONE',
  //     'LDONE',
  //     'MDONE',
  //     'NDONE',
  //     'ODONE',
  //     'PDONE',
  //     'QDONE',
  //     'RDONE',
  //     'SDONE',
  //     'TDONE',
  //     'UDONE',
  //     'VDONE',
  //     'WDONE',
  //     'XDONE',
  //     'YDONE',
  //     'ZDONE',
  //   ];
  //
  //   static const List<String> _realWordList = [
  //     'ABOUT',
  //     'ABOVE',
  //     'ABUSE',
  //     'ACTOR',
  //     'ACUTE',
  //     'ADMIT',
  //     'ADOPT',
  //     'ADULT',
  //     'AFTER',
  //     'AGAIN',
  //     'AGENT',
  //     'AGREE',
  //     'AHEAD',
  //     'ALARM',
  //     'ALBUM',
  //     'ALERT',
  //     'ALIEN',
  //     'ALIGN',
  //     'ALIKE',
  //     'ALIVE',
  //     'ALLOW',
  //     'ALONE',
  //     'ALONG',
  //     'ALTER',
  //     'AMONG',
  //     'ANGER',
  //     'ANGLE',
  //     'ANGRY',
  //     'APART',
  //     'APPLE',
  //     'APPLY',
  //     'ARENA',
  //     'ARGUE',
  //     'ARISE',
  //     'ARRAY',
  //     'ASIDE',
  //     'ASSET',
  //     'AUDIO',
  //     'AUDIT',
  //     'AVOID',
  //     'AWAKE',
  //     'AWARD',
  //     'AWARE',
  //     'BADLY',
  //     'BAKER',
  //     'BASES',
  //     'BASIC',
  //     'BEACH',
  //     'BEGAN',
  //     'BEGIN',
  //     'BEING',
  //     'BELOW',
  //     'BENCH',
  //     'BILLY',
  //     'BIRTH',
  //     'BLACK',
  //     'BLAME',
  //     'BLANK',
  //     'BLIND',
  //     'BLOCK',
  //     'BLOOD',
  //     'BOARD',
  //     'BOOST',
  //     'BOOTH',
  //     'BOUND',
  //     'BRAIN',
  //     'BRAND',
  //     'BRASS',
  //     'BRAVE',
  //     'BREAD',
  //     'BREAK',
  //     'BREED',
  //     'BRIEF',
  //     'BRING',
  //     'BROAD',
  //     'BROKE',
  //     'BROWN',
  //     'BUILD',
  //     'BUILT',
  //     'BUYER',
  //     'CABLE',
  //     'CALIF',
  //     'CARRY',
  //     'CATCH',
  //     'CAUSE',
  //     'CHAIN',
  //     'CHAIR',
  //     'CHAOS',
  //     'CHARM',
  //     'CHART',
  //     'CHASE',
  //     'CHEAP',
  //     'CHECK',
  //     'CHEST',
  //     'CHIEF',
  //     'CHILD',
  //     'CHINA',
  //     'CHOSE',
  //     'CIVIL',
  //     'CLAIM',
  //     'CLASS',
  //     'CLEAN',
  //     'CLEAR',
  //     'CLICK',
  //     'CLIMB',
  //     'CLOCK',
  //     'CLOSE',
  //     'CLOUD',
  //     'COACH',
  //     'COAST',
  //     'COULD',
  //     'COUNT',
  //     'COURT',
  //     'COVER',
  //     'CRAFT',
  //     'CRASH',
  //     'CRAZY',
  //     'CREAM',
  //     'CRIME',
  //     'CROSS',
  //     'CROWD',
  //     'CROWN',
  //     'CRUDE',
  //     'CURVE',
  //     'CYCLE',
  //     'DAILY',
  //     'DANCE',
  //     'DATED',
  //     'DEALT',
  //     'DEATH',
  //     'DEBUT',
  //     'DELAY',
  //     'DEPTH',
  //     'DOING',
  //     'DOUBT',
  //     'DOZEN',
  //     'DRAFT',
  //     'DRAMA',
  //     'DRANK',
  //     'DRAWN',
  //     'DREAM',
  //     'DRESS',
  //     'DRILL',
  //     'DRINK',
  //     'DRIVE',
  //     'DROVE',
  //     'DYING',
  //     'EAGER',
  //     'EARLY',
  //     'EARTH',
  //     'EIGHT',
  //     'ELITE',
  //     'EMPTY',
  //     'ENEMY',
  //     'ENJOY',
  //     'ENTER',
  //     'ENTRY',
  //     'EQUAL',
  //     'ERROR',
  //     'EVENT',
  //     'EVERY',
  //     'EXACT',
  //     'EXIST',
  //     'EXTRA',
  //     'FAITH',
  //     'FALSE',
  //     'FAULT',
  //     'FIBER',
  //     'FIELD',
  //     'FIFTH',
  //     'FIFTY',
  //     'FIGHT',
  //     'FINAL',
  //     'FIRST',
  //     'FIXED',
  //     'FLASH',
  //     'FLEET',
  //     'FLOOR',
  //     'FLUID',
  //     'FOCUS',
  //     'FORCE',
  //     'FORTH',
  //     'FORTY',
  //     'FORUM',
  //     'FOUND',
  //     'FRAME',
  //     'FRANK',
  //     'FRAUD',
  //     'FRESH',
  //     'FRONT',
  //     'FROST',
  //     'FRUIT',
  //     'FULLY',
  //     'FUNNY',
  //     'GIANT',
  //     'GIVEN',
  //     'GLASS',
  //     'GLOBE',
  //     'GOING',
  //     'GRACE',
  //     'GRADE',
  //     'GRAND',
  //     'GRANT',
  //     'GRASS',
  //     'GRAVE',
  //     'GREAT',
  //     'GREEN',
  //     'GROSS',
  //     'GROUP',
  //     'GROWN',
  //     'GUARD',
  //     'GUESS',
  //     'GUEST',
  //     'GUIDE',
  //     'HAPPY',
  //     'HARRY',
  //     'HEART',
  //     'HEAVY',
  //     'HORSE',
  //     'HOTEL',
  //     'HOUSE',
  //     'HUMAN',
  //     'IDEAL',
  //     'IMAGE',
  //     'INDEX',
  //     'INNER',
  //     'INPUT',
  //     'ISSUE',
  //     'JAPAN',
  //     'JIMMY',
  //     'JOINT',
  //     'JONES',
  //     'JUDGE',
  //     'KNOWN',
  //     'LABEL',
  //     'LARGE',
  //     'LASER',
  //     'LATER',
  //     'LAUGH',
  //     'LAYER',
  //     'LEARN',
  //     'LEASE',
  //     'LEAST',
  //     'LEAVE',
  //     'LEGAL',
  //     'LEVEL',
  //     'LEWIS',
  //     'LIGHT',
  //     'LIMIT',
  //     'LINKS',
  //     'LIVES',
  //     'LOCAL',
  //     'LOOSE',
  //     'LOWER',
  //     'LUCKY',
  //     'LUNCH',
  //     'LYING',
  //     'MAGIC',
  //     'MAJOR',
  //     'MAKER',
  //     'MARCH',
  //     'MARIA',
  //     'MATCH',
  //     'MAYBE',
  //     'MAYOR',
  //     'MEANT',
  //     'MEDIA',
  //     'METAL',
  //     'MIGHT',
  //     'MINOR',
  //     'MINUS',
  //     'MIXED',
  //     'MODEL',
  //     'MONEY',
  //     'MONTH',
  //     'MORAL',
  //     'MOTOR',
  //     'MOUNT',
  //     'MOUSE',
  //     'MOUTH',
  //     'MOVED',
  //     'MOVIE',
  //     'MUSIC',
  //     'NEEDS',
  //     'NEVER',
  //     'NEWLY',
  //     'NIGHT',
  //     'NOISE',
  //     'NORTH',
  //     'NOTED',
  //     'NOVEL',
  //     'NURSE',
  //     'OCCUR',
  //     'OCEAN',
  //     'OFFER',
  //     'OFTEN',
  //     'ORDER',
  //     'OTHER',
  //     'OUGHT',
  //     'PAINT',
  //     'PANEL',
  //     'PAPER',
  //     'PARTY',
  //     'PEACE',
  //     'PETER',
  //     'PHASE',
  //     'PHONE',
  //     'PHOTO',
  //     'PIANO',
  //     'PIECE',
  //     'PILOT',
  //     'PITCH',
  //     'PLACE',
  //     'PLAIN',
  //     'PLANE',
  //     'PLANT',
  //     'PLATE',
  //     'PLAZA',
  //     'PLOT',
  //     'PLUG',
  //     'PLUS',
  //     'POINT',
  //     'POUND',
  //     'POWER',
  //     'PRESS',
  //     'PRICE',
  //     'PRIDE',
  //     'PRIME',
  //     'PRINT',
  //     'PRIOR',
  //     'PRIZE',
  //     'PROOF',
  //     'PROUD',
  //     'PROVE',
  //     'QUEEN',
  //     'QUICK',
  //     'QUIET',
  //     'QUITE',
  //     'RADIO',
  //     'RAISE',
  //     'RANGE',
  //     'RAPID',
  //     'RATIO',
  //     'REACH',
  //     'READY',
  //     'REALM',
  //     'REBEL',
  //     'REFER',
  //     'RELAX',
  //     'REPAY',
  //     'REPLY',
  //     'RIGHT',
  //     'RIGID',
  //     'RIVER',
  //     'ROBIN',
  //     'ROGER',
  //     'ROMAN',
  //     'ROUGH',
  //     'ROUND',
  //     'ROUTE',
  //     'ROYAL',
  //     'RURAL',
  //     'SCALE',
  //     'SCENE',
  //     'SCOPE',
  //     'SCORE',
  //     'SENSE',
  //     'SERVE',
  //     'SETUP',
  //     'SEVEN',
  //     'SHALL',
  //     'SHAPE',
  //     'SHARE',
  //     'SHARP',
  //     'SHEET',
  //     'SHELF',
  //     'SHELL',
  //     'SHIFT',
  //     'SHINE',
  //     'SHIRT',
  //     'SHOCK',
  //     'SHOOT',
  //     'SHORT',
  //     'SHOWN',
  //     'SIDED',
  //     'SIGHT',
  //     'SILLY',
  //     'SINCE',
  //     'SIXTH',
  //     'SIXTY',
  //     'SIZED',
  //     'SKILL',
  //     'SLEEP',
  //     'SLIDE',
  //     'SMALL',
  //     'SMART',
  //     'SMILE',
  //     'SMITH',
  //     'SMOKE',
  //     'SNAKE',
  //     'SNOW',
  //     'SOLAR',
  //     'SOLID',
  //     'SOLVE',
  //     'SORRY',
  //     'SOUND',
  //     'SOUTH',
  //     'SPACE',
  //     'SPARE',
  //     'SPEAK',
  //     'SPEED',
  //     'SPEND',
  //     'SPENT',
  //     'SPLIT',
  //     'SPOKE',
  //     'SPORT',
  //     'SQUAD',
  //     'STACK',
  //     'STAFF',
  //     'STAGE',
  //     'STAKE',
  //     'STAND',
  //     'START',
  //     'STATE',
  //     'STEAM',
  //     'STEEL',
  //     'STEEP',
  //     'STEER',
  //     'STEPS',
  //     'STICK',
  //     'STILL',
  //     'STOCK',
  //     'STONE',
  //     'STOOD',
  //     'STORE',
  //     'STORM',
  //     'STORY',
  //     'STRIP',
  //     'STUCK',
  //     'STUDY',
  //     'STUFF',
  //     'STYLE',
  //     'SUGAR',
  //     'SUITE',
  //     'SUPER',
  //     'SWEET',
  //     'TABLE',
  //     'TAKEN',
  //     'TASTE',
  //     'TAXES',
  //     'TEACH',
  //     'TEETH',
  //     'TERRY',
  //     'TEXAS',
  //     'THANK',
  //     'THEFT',
  //     'THEIR',
  //     'THEME',
  //     'THERE',
  //     'THESE',
  //     'THICK',
  //     'THING',
  //     'THINK',
  //     'THIRD',
  //     'THOSE',
  //     'THREE',
  //     'THREW',
  //     'THROW',
  //     'THUMB',
  //     'TIGHT',
  //     'TIMER',
  //     'TIMES',
  //     'TITLE',
  //     'TODAY',
  //     'TOPIC',
  //     'TOTAL',
  //     'TOUCH',
  //     'TOUGH',
  //     'TOWER',
  //     'TRACK',
  //     'TRADE',
  //     'TRAIN',
  //     'TREAT',
  //     'TREND',
  //     'TRIAL',
  //     'TRIBE',
  //     'TRICK',
  //     'TRIED',
  //     'TRIES',
  //     'TRUCK',
  //     'TRULY',
  //     'TRUNK',
  //     'TRUST',
  //     'TRUTH',
  //     'TWICE',
  //     'TWIST',
  //     'TYLER',
  //     'UNDER',
  //     'UNDUE',
  //     'UNION',
  //     'UNITY',
  //     'UNTIL',
  //     'UPPER',
  //     'UPSET',
  //     'URBAN',
  //     'USAGE',
  //     'USUAL',
  //     'VALID',
  //     'VALUE',
  //     'VIDEO',
  //     'VIRUS',
  //     'VISIT',
  //     'VITAL',
  //     'VOCAL',
  //     'VOICE',
  //     'WASTE',
  //     'WATCH',
  //     'WATER',
  //     'WAVES',
  //     'WAYS',
  //     'WEIRD',
  //     'WELSH',
  //     'WHEEL',
  //     'WHERE',
  //     'WHICH',
  //     'WHILE',
  //     'WHITE',
  //     'WHOLE',
  //     'WHOSE',
  //     'WOMAN',
  //     'WOMEN',
  //     'WORLD',
  //     'WORRY',
  //     'WORSE',
  //     'WORST',
  //     'WORTH',
  //     'WOULD',
  //     'WRITE',
  //     'WRONG',
  //     'WROTE',
  //     'YARDS',
  //     'YEARS',
  //     'YOUNG',
  //     'YOUTH',
  //     'YOURS',
  //     'YOURSELF',
  //     'YOUTH',
  //     'ZONES',
  //     'ZONAL',
  //     'ZONED',
  //   // ];

  // Mock data generation method removed - only real words from assets allowed

  List<Word> _wordList = [];
  List<Word> _guessWords = [];
  final List<Word> _answerWords = [];
  bool _isLoaded = false;
  bool _isGuessWordsLoaded = false;
  bool _isAnswerWordsLoaded = false;

  /// The main word list
  List<Word> get wordList {
    if (!_isLoaded) {
      throw ServiceNotInitializedException('Word list not loaded');
    }
    return _wordList;
  }

  /// The guess words list (big list for filtering)
  List<Word> get guessWords {
    if (!_isGuessWordsLoaded) {
      throw ServiceNotInitializedException('Guess words not loaded');
    }
    return _guessWords;
  }

  /// The answer words list (small list for suggestions)
  List<Word> get answerWords {
    if (!_isAnswerWordsLoaded) {
      throw ServiceNotInitializedException('Answer words not loaded');
    }
    return _answerWords;
  }

  /// Whether the word list is loaded
  bool get isLoaded => _isLoaded;

  /// Whether the guess words are loaded
  bool get isGuessWordsLoaded => _isGuessWordsLoaded;

  /// Size of the word list
  int get wordListSize => _wordList.length;

  /// Size of the guess words list
  int get guessWordsSize => _guessWords.length;

  /// Size of the answer words list
  int get answerWordsSize => _answerWords.length;

  /// Loads word list from assets using FFI
  Future<void> loadWordList(String assetPath) async {
    DebugLogger.info(
      '🔧 WordService: Starting loadWordList with path: $assetPath',
      tag: 'WordService',
    );
    DebugLogger.debug(
      'contains test: ${assetPath.contains('test')}',
      tag: 'WordService',
    );
    DebugLogger.debug(
      'contains assets: ${assetPath.contains('assets')}',
      tag: 'WordService',
    );
    DebugLogger.debug(
      'contains missing: ${assetPath.contains('missing')}',
      tag: 'WordService',
    );
    DebugLogger.debug(
      'contains wordle_words.json: ${assetPath.contains('wordle_words.json')}',
      tag: 'WordService',
    );

    // Always try to load real word list - no mock data fallback

    try {
      DebugLogger.debug(
        'Attempting to load real word list via FFI',
        tag: 'WordService',
      );
      // Use FFI service to load word lists
      final words = await FfiService.loadWordListsFromJsonFile(assetPath);
      DebugLogger.debug('FFI loaded ${words.length} words', tag: 'WordService');

      _wordList = words
          .map((wordStr) => Word.fromString(wordStr))
          .where((word) => word.isValid && word.length == 5)
          .toList();

      _isLoaded = true;
    } catch (e) {
      // Fallback to original method if FFI fails
      try {
        final String jsonString = await rootBundle.loadString(assetPath);
        final Map<String, dynamic> jsonData = jsonDecode(jsonString);
        
        // Handle both direct array and structured JSON formats
        List<dynamic> wordsJson;
        if (jsonData.containsKey('guess_words')) {
          wordsJson = jsonData['guess_words'] as List<dynamic>;
        } else if (jsonData.containsKey('answer_words')) {
          wordsJson = jsonData['answer_words'] as List<dynamic>;
        } else {
          // Assume it's a direct array
          wordsJson = jsonData.values.first as List<dynamic>;
        }

        _wordList = wordsJson
            .map((wordJson) {
              String wordStr = wordJson as String;
              // Remove quotes if present
              if (wordStr.startsWith("'") && wordStr.endsWith("'")) {
                wordStr = wordStr.substring(1, wordStr.length - 1);
              }
              return Word.fromString(wordStr);
            })
            .where((word) => word.isValid && word.length == 5)
            .toList();

        _isLoaded = true;
      } catch (fallbackError) {
        // HARD FAILURE: No fallback allowed - assets must be available
        DebugLogger.error(
          '❌ CRITICAL: Failed to load word list from FFI: $e',
          tag: 'WordService',
        );
        DebugLogger.error(
          '❌ CRITICAL: Failed to load word list from JSON fallback: $fallbackError',
          tag: 'WordService',
        );
        DebugLogger.error(
          '❌ CRITICAL: Asset not found or corrupted: $assetPath',
          tag: 'WordService',
        );

        throw AssetLoadException(
          'CRITICAL FAILURE: Cannot load required word list from $assetPath. '
          'Both FFI and JSON loading failed. This is a fatal error - the app cannot function without proper word lists. '
          'FFI Error: $e, JSON Error: $fallbackError',
        );
      }
    }
  }

  /// Loads guess words from assets
  Future<void> loadGuessWords(String assetPath) async {
    DebugLogger.info(
      '🔧 WordService: Starting loadGuessWords with path: $assetPath',
      tag: 'WordService',
    );
    // Always try to load real word list - no mock data fallback

    try {
      // Check if it's a JSON file
      if (assetPath.endsWith('.json')) {
        // Load as JSON array or structured JSON
        final String jsonString = await rootBundle.loadString(assetPath);
        final Map<String, dynamic> jsonData = jsonDecode(jsonString);
        
        // Handle both direct array and structured JSON formats
        List<dynamic> wordsJson;
        if (jsonData.containsKey('guess_words')) {
          wordsJson = jsonData['guess_words'] as List<dynamic>;
        } else if (jsonData.containsKey('answer_words')) {
          wordsJson = jsonData['answer_words'] as List<dynamic>;
        } else {
          // Assume it's a direct array
          wordsJson = jsonData.values.first as List<dynamic>;
        }

        _guessWords = wordsJson
            .map((wordJson) {
              String wordStr = wordJson as String;
              // Remove quotes if present
              if (wordStr.startsWith("'") && wordStr.endsWith("'")) {
                wordStr = wordStr.substring(1, wordStr.length - 1);
              }
              return Word.fromString(wordStr);
            })
            .where((word) => word.isValid && word.length == 5)
            .toList();
      } else {
        // Load as text file
        final String text = await rootBundle.loadString(assetPath);
        final List<String> lines = text.split('\n');

        _guessWords = lines
            .where((line) => line.trim().isNotEmpty)
            .map((line) => Word.fromString(line.trim()))
            .where((word) => word.isValid && word.length == 5)
            .toList();
      }

      _isGuessWordsLoaded = true;
    } catch (e) {
      // HARD FAILURE: No fallback allowed - assets must be available
      DebugLogger.error(
        '❌ CRITICAL: Failed to load guess words from asset: $assetPath',
        tag: 'WordService',
      );
      DebugLogger.error('❌ CRITICAL: Error details: $e', tag: 'WordService');
      throw AssetLoadException(
        'CRITICAL FAILURE: Cannot load required guess words from $assetPath. '
        'This is a fatal error - the app cannot function without proper word lists. '
        'Error: $e',
      );
    }
  }

  /// Loads answer words from JSON file (the ~2.3k Wordle answer list)
  Future<void> loadAnswerWords(String assetPath) async {
    DebugLogger.info(
      '🔧 WordService: Starting loadAnswerWords with path: $assetPath',
      tag: 'WordService',
    );

    try {
      // Load as JSON array or structured JSON
      final String jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      
      // Handle both direct array and structured JSON formats
      List<dynamic> wordsJson;
      if (jsonData.containsKey('answer_words')) {
        wordsJson = jsonData['answer_words'] as List<dynamic>;
      } else if (jsonData.containsKey('guess_words')) {
        wordsJson = jsonData['guess_words'] as List<dynamic>;
      } else {
        // Assume it's a direct array
        wordsJson = jsonData.values.first as List<dynamic>;
      }

      _answerWords.clear();
      _answerWords.addAll(
        wordsJson
            .map((wordJson) {
              String wordStr = wordJson as String;
              // Remove quotes if present
              if (wordStr.startsWith("'") && wordStr.endsWith("'")) {
                wordStr = wordStr.substring(1, wordStr.length - 1);
              }
              return Word.fromString(wordStr);
            })
            .where((word) => word.isValid && word.length == 5)
            .toList(),
      );

      _isAnswerWordsLoaded = true;
      DebugLogger.success(
        'Loaded ${_answerWords.length} answer words',
        tag: 'WordService',
      );
    } catch (e) {
      DebugLogger.error('Failed to load answer words: $e', tag: 'WordService');
      throw AssetLoadException('Failed to load answer words: $e');
    }
  }

  /// Validates the word list
  bool validateWordList() {
    if (!_isLoaded) {
      throw ServiceNotInitializedException('Word list not loaded');
    }
    return _wordList.every((word) => word.isValid);
  }

  /// Filters words by length
  List<Word> filterWordsByLength(int length) {
    if (!_isLoaded) {
      throw ServiceNotInitializedException('Word list not loaded');
    }
    return _wordList.where((word) => word.length == length).toList();
  }

  /// Filters words by pattern
  List<Word> filterWordsByPattern(String? pattern) {
    if (!_isLoaded) {
      throw ServiceNotInitializedException('Word list not loaded');
    }

    if (pattern == null || pattern.isEmpty) {
      throw InvalidPatternException('Pattern cannot be empty');
    }

    if (pattern.length != 5) {
      throw InvalidPatternException('Pattern must be 5 characters long');
    }

    return _wordList.where((word) {
      for (int i = 0; i < pattern.length; i++) {
        if (pattern[i] != '?' && word[i] != pattern[i]) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Filters words containing a specific letter
  List<Word> filterWordsContainingLetter(String? letter) {
    if (!_isLoaded) {
      throw ServiceNotInitializedException('Word list not loaded');
    }

    if (letter == null || letter.isEmpty) {
      throw InvalidLetterException('Letter cannot be empty');
    }

    return _wordList.where((word) => word.containsLetter(letter)).toList();
  }

  /// Filters words not containing a specific letter
  List<Word> filterWordsNotContainingLetter(String letter) {
    if (!_isLoaded) {
      throw ServiceNotInitializedException('Word list not loaded');
    }

    if (letter.isEmpty) {
      throw InvalidLetterException('Letter cannot be empty');
    }

    return _wordList.where((word) => !word.containsLetter(letter)).toList();
  }

  /// Filters words by multiple criteria
  List<Word> filterWordsByMultipleCriteria({
    String? pattern,
    List<String>? mustContain,
  }) {
    if (!_isLoaded) {
      throw ServiceNotInitializedException('Word list not loaded');
    }

    List<Word> result = _wordList;

    if (pattern != null && pattern.isNotEmpty) {
      result = result.where((word) {
        for (int i = 0; i < pattern.length; i++) {
          if (pattern[i] != '?' && word[i] != pattern[i]) {
            return false;
          }
        }
        return true;
      }).toList();
    }

    if (mustContain != null) {
      for (String letter in mustContain) {
        result = result.where((word) => word.containsLetter(letter)).toList();
      }
    }

    return result;
  }

  /// Advanced filtering using Rust solver based on guess results
  /// This is the main method that will use the FFI bridge
  List<Word> filterWordsByGuessResults(List<ffi.FfiGuessResult> guessResults) {
    if (!_isLoaded) {
      throw ServiceNotInitializedException('Word list not loaded');
    }

    try {
      // Convert Word objects to strings for FFI
      final allWords = _wordList.map((word) => word.value).toList();

      // Convert guess results to our format
      final convertedGuessResults = guessResults.map((result) => (
        result.word,
        result.results.map((r) => r.toString().split('.').last).toList()
      )).toList();
      
      // Use the Rust solver for advanced filtering
      final filteredWords = FfiService.filterWords(allWords, convertedGuessResults);

      // Convert back to Word objects
      return filteredWords.map((wordStr) => Word.fromString(wordStr)).toList();
    } catch (e) {
      throw ServiceNotInitializedException(
        'Failed to filter words using Rust solver: $e',
      );
    }
  }

  /// Get best guess suggestion using Rust solver
  String? getBestGuessSuggestion(List<Word> remainingWords) {
    if (!_isLoaded) {
      throw ServiceNotInitializedException('Word list not loaded');
    }

    try {
      final allWords = _wordList.map((word) => word.value).toList();
      final remainingWordsStr = remainingWords
          .map((word) => word.value)
          .toList();

      return FfiService.getBestGuess(allWords, remainingWordsStr, []);
    } catch (e) {
      throw ServiceNotInitializedException(
        'Failed to get best guess suggestion: $e',
      );
    }
  }

  /// Finds a word in the word list
  Word? findWord(String searchWord) {
    if (!_isLoaded) {
      throw ServiceNotInitializedException('Word list not loaded');
    }

    final word = Word.fromString(searchWord);
    try {
      return _wordList.firstWhere((w) => w == word);
    } catch (e) {
      return null;
    }
  }

  /// Finds words by partial match
  List<Word> findWordsByPartialMatch(String partialWord) {
    if (!_isLoaded) {
      throw ServiceNotInitializedException('Word list not loaded');
    }

    return _wordList
        .where((word) => word.value.startsWith(partialWord))
        .toList();
  }

  /// Finds words by letter frequency
  List<Word> findWordsByLetterFrequency(String letter, int count) {
    if (!_isLoaded) {
      throw ServiceNotInitializedException('Word list not loaded');
    }

    return _wordList
        .where((word) => word.countLetter(letter) == count)
        .toList();
  }

  /// Gets letter frequency distribution
  Map<String, int> getLetterFrequencyDistribution() {
    if (!_isLoaded) {
      throw ServiceNotInitializedException('Word list not loaded');
    }

    final Map<String, int> distribution = {};

    for (Word word in _wordList) {
      for (String letter in word.value.split('')) {
        distribution[letter] = (distribution[letter] ?? 0) + 1;
      }
    }

    return distribution;
  }

  /// Gets most common letters
  List<String> getMostCommonLetters(int count) {
    if (!_isLoaded) {
      throw ServiceNotInitializedException('Word list not loaded');
    }

    final distribution = getLetterFrequencyDistribution();
    final sortedLetters = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedLetters.take(count).map((e) => e.key).toList();
  }

  /// Gets least common letters
  List<String> getLeastCommonLetters(int count) {
    if (!_isLoaded) {
      throw ServiceNotInitializedException('Word list not loaded');
    }

    final distribution = getLetterFrequencyDistribution();
    final sortedLetters = distribution.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return sortedLetters.take(count).map((e) => e.key).toList();
  }

  // REMOVED: loadFallbackWordList() method
  // No fallback word lists allowed - app must fail hard if assets cannot be loaded
  // This ensures we never silently degrade to bad word lists
}
