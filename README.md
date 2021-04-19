# Grafon

A graphical phonetic constructed script and language, i.e. Conlang & Conscript.

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
    final sun = Mono.Sun.gram; 
    expect(sun.toString(), "Sun");
    expect(sun.pronunciation, "Za");

    final house = Quads.Angle.up.merge(Quads.Gate.down);
    expect(house.toString(), "Angle up * Gate down");
    expect(house.pronunciation, "GiDu");

    final person = Mono.Dot.gram.over(Quads.Line.up);
    expect(person.toString(), "Dot / Line up");
    expect(person.pronunciation, "ArI");

    final rain = Quads.Flow.down.before(Quads.Flow.down);
    expect(rain.toString(), "Flow down | Flow down");
    expect(rain.pronunciation, "VuzVu");

    final speech = Quads.Gate.left.around(Quads.Flow.right);
    expect(speech.toString(), "Gate left @ Flow right");
    expect(speech.pronunciation, "DonVe");

    final starMan = sun.compound(person); // God? Alien?
    expect(starMan.toString(), "Sun : Dot / Line up");
    expect(starMan.pronunciation, "ZangArI");

    // Red is the light from a Flower
    final red = Mono.Light.gram.around(Mono.Flower.gram);
    expect(red.toString(), "Light @ Flower");
    expect(red.pronunciation, "JanVa");
  });
```

![House](/assets/images/house.png)
![Human](/assets/images/human.png)
![Rain](/assets/images/rain.png)
![Speech](/assets/images/speech.png)
![Red](/assets/images/red.png)
![Star-being](/assets/images/star-being.png)

## Development Notes
* [Test Coverage Reports](https://app.codecov.io/gh/bguan/grafon) – aim for 100%.
