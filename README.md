# Grafon

An app to develop my graphical phonetic constructed script and language, i.e. Conlang & Conscript.

A live site built with flutter web is hosted on [grafon.org](https://grafon.org/).

Logo-grams, i.e. graphical symbols, AKA Grams, arranged in a table, are each associated with a 
syllable (an optional starting consonant and a mandatory vowel).  

![Gra Table](/assets/images/gramtable.png)

The grams can be further arranged in a handful of 2 dimensional operations to form words.

An unary operation manipulating a gram is associated with an ending 
vowel to be appended to the gram, forming a diphthong.

A binary operation manipulating 2 symbols (or expressions) is associated with an ending 
consonant to be appended to gram as coda.

## Example in Code
```
  test('BinaryExpr toString and pronunciation is correct', () {
    final sun = Mono.Sun.gram; // or star
    expect(sun.toString(), "Sun");
    expect(sun.pronunciation.first, Syllable(Consonant.S, Vowel.A)); // "Sa"

    final house = Quads.Angle.up.merge(Quads.Gate.down);
    expect(house.toString(), "Angle up * Gate down");
    expect(house.pronunciation.length, 2); // "Gir-Du"
    expect(house.pronunciation.first,
        Syllable.cvc(Consonant.G, Vowel.I, EndConsonant.R));
    expect(house.pronunciation.last, Syllable(Consonant.D, Vowel.U));

    final person = Mono.Dot.gram.over(Quads.Line.up);
    expect(person.toString(), "Dot / Line up");
    expect(person.pronunciation.length, 2); // "As-I"
    expect(person.pronunciation.first, Syllable.vc(Vowel.A, EndConsonant.S));
    expect(person.pronunciation.last, Syllable.v(Vowel.I));

    final rain = Quads.Flow.down.next(Quads.Flow.down);
    expect(rain.toString(), "Flow down | Flow down");
    expect(rain.pronunciation.length, 2); // "Fu-Fu"
    expect(rain.pronunciation.first, Syllable(Consonant.F, Vowel.U));
    expect(rain.pronunciation.last, Syllable(Consonant.F, Vowel.U));

    final speech = Quads.Gate.left.wrap(Quads.Flow.right);
    expect(speech.toString(), "Gate left @ Flow right");
    expect(speech.pronunciation.length, 2); // "Don-Fe"
    expect(speech.pronunciation.first,
        Syllable.cvc(Consonant.D, Vowel.O, EndConsonant.N));
    expect(speech.pronunciation.last, Syllable(Consonant.F, Vowel.E));

    final red = Mono.Light.gram.wrap(Mono.Flower.gram);
    expect(red.toString(), "Light @ Flower");
    expect(red.pronunciation.length, 2); // "Chan-Fa"
    expect(red.pronunciation.first,
        Syllable.cvc(Consonant.Ch, Vowel.A, EndConsonant.N));
    expect(red.pronunciation.last, Syllable(Consonant.F, Vowel.A));
  });

  test("CompoundWord pronunciation", () {
    final sun = Mono.Sun.gram; // or star
    final person = Mono.Dot.gram.over(Quads.Line.up);

    final starMan = CompoundWord([sun, person]); // God? Alien?
    expect(starMan.toString(), "Sun : Dot / Line up");
    List<Syllable> syllables = starMan.pronunciation.toList();
    expect(syllables.length, 3); // "Sang-As-I"
    expect(syllables[0], Syllable.cvc(Consonant.S, Vowel.A, EndConsonant.ng));
    expect(syllables[1], Syllable.vc(Vowel.A, EndConsonant.S));
    expect(syllables[2], Syllable.v(Vowel.I));
  });

```

| Gram Expression | Meaning |
| --:             | :--     |
| <img src="https://github.com/bguan/grafon/blob/main/assets/images/house.png?raw=true" width="75" height="100" alt="House"/> | House |
| <img src="https://github.com/bguan/grafon/blob/main/assets/images/human.png?raw=true" width="75" height="100" alt="Human"/> | Human |
| <img src="https://github.com/bguan/grafon/blob/main/assets/images/rain.png?raw=true" width="100" height="100" alt="Rain"/> | Rain |
| <img src="https://github.com/bguan/grafon/blob/main/assets/images/speech.png?raw=true" width="100" height="100" alt="Speech"/> | Speech |
| <img src="https://github.com/bguan/grafon/blob/main/assets/images/red.png?raw=true" width="100" height="100" alt="Red"/> | Red |
| <img src="https://github.com/bguan/grafon/blob/main/assets/images/star-being.png?raw=true" width="150" height="100" alt="Star-Being"/> | Star-Being, Alien, God! |


## Development Notes
* [Test Coverage Reports](https://app.codecov.io/gh/bguan/grafon) – aim for 100%.
