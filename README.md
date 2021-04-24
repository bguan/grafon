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
    expect(sun.pronunciation, "Za");

    final house = Quads.Angle.up.merge(Quads.Gate.down);
    expect(house.toString(), "Angle up * Gate down");
    expect(house.pronunciation, "GiDu");

    final person = Mono.Dot.gram.over(Quads.Line.up);
    expect(person.toString(), "Dot / Line up");
    expect(person.pronunciation, "AgI");

    final rain = Quads.Flow.down.before(Quads.Flow.down);
    expect(rain.toString(), "Flow down | Flow down");
    expect(rain.pronunciation, "VuzVu");

    final speech = Quads.Gate.left.around(Quads.Flow.right);
    expect(speech.toString(), "Gate left @ Flow right");
    expect(speech.pronunciation, "DonVe");

    final starMan = sun.compound(person); // God? Alien?
    expect(starMan.toString(), "Sun : Dot / Line up");
    expect(starMan.pronunciation, "ZangAgI");

    // Red is the light from a Flower
    final red = Mono.Light.gram.around(Mono.Flower.gram);
    expect(red.toString(), "Light @ Flower");
    expect(red.pronunciation, "JanVa");
  });
```

| Gram Expression | Meaning |
| --:             | :--     |
| <img src="https://github.com/bguan/grafon/blob/main/assets/images/house.png?raw=true" width="100" height="100" alt="House"/> | House |
| <img src="https://github.com/bguan/grafon/blob/main/assets/images/human.png?raw=true" width="75" height="100" alt="Human"/> | Human |
| <img src="https://github.com/bguan/grafon/blob/main/assets/images/rain.png?raw=true" width="100" height="100" alt="Human"/> | Rain |
| <img src="https://github.com/bguan/grafon/blob/main/assets/images/speech.png?raw=true" width="100" height="100" alt="Human"/> | Speech |
| <img src="https://github.com/bguan/grafon/blob/main/assets/images/red.png?raw=true" width="100" height="100" alt="Human"/> | Red |
| <img src="https://github.com/bguan/grafon/blob/main/assets/images/star-being.png?raw=true" width="150" height="100" alt="Human"/> | Star-Being! |


## Development Notes
* [Test Coverage Reports](https://app.codecov.io/gh/bguan/grafon) – aim for 100%.
