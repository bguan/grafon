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
    final sun = Mono.Sun.gram; // or star
    expect(sun.toString(), "Sun");
    expect(sun.pronunciation, "Ra");

    final house = Quads.Angle.up.over(Quads.Gate.down);
    expect(house.toString(), "Angle up / Gate down");
    expect(house.pronunciation, "GisDu");

    final person = Mono.Dot.gram.over(Quads.Line.up);
    expect(person.toString(), "Dot / Line up");
    expect(person.pronunciation, "AsI");

    final day = sun.over(Quads.Line.down);
    expect(day.toString(), "Sun / Line down");
    expect(day.pronunciation, "RasU");

    final rain = Quads.Flow.down.before(Quads.Flow.down);
    expect(rain.toString(), "Flow down | Flow down");
    expect(rain.pronunciation, "VuVu");

    final speech = Quads.Arc.left.before(Quads.Flow.right);
    expect(speech.toString(), "Arc left | Flow right");
    expect(speech.pronunciation, "NoVe");

    final nine = Mono.Square.gram.merge(Quads.Line.up);
    expect(nine.toString(), "Square * Line up");
    expect(nine.pronunciation, "DalI");

    final starMan = sun.compound(person); // God? Alien?
    expect(starMan.toString(), "Sun : Dot / Line up");
    expect(starMan.pronunciation, "RangAsI");

    // Red is the light from a Flower
    final red = Mono.Light.gram.around(Mono.Flower.gram);
    expect(red.toString(), "Light @ Flower");
    expect(red.pronunciation, "ZamVa");
  });
```

## Development Notes
* [Test Coverage Reports](https://app.codecov.io/gh/bguan/grafon) – aim for 100%.
