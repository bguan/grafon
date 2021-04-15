# Grafon

A graphical phonetic language.  

Logo-grams, i.e. graphical symbols, AKA Grams, arranged in a table, are each associated with a syllable (an optional starting 
consonant and a vowel).  

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

    final house = Quads.Angle.up.over(Quads.Gate.up);
    expect(house.toString(), "Angle.Up / Gate.Up");
    expect(house.pronunciation, "GisDi");

    final person = Mono.Dot.gram.over(Quads.Line.up);
    expect(person.toString(), "Dot / Line.Up");
    expect(person.pronunciation, "AsI");

    final day = sun.over(Quads.Line.down);
    expect(day.toString(), "Sun / Line.Down");
    expect(day.pronunciation, "ZasU");

    final rain = Quads.Flow.down.before(Quads.Flow.down);
    expect(rain.toString(), "Flow.Down | Flow.Down");
    expect(rain.pronunciation, "VuVu");

    final speech = Quads.Arc.right.around(Quads.Flow.right);
    expect(speech.toString(), "Arc.Right @ Flow.Right");
    expect(speech.pronunciation, "NemVe");

    final nine = Mono.Square.gram.merge(Quads.Line.up);
    expect(nine.toString(), "Square * Line.Up");
    expect(nine.pronunciation, "DalI");

    final starMan = sun.compound(person); // God? Alien?
    expect(starMan.toString(), "Sun : Dot / Line.Up");
    expect(starMan.pronunciation, "ZangAsI");
  });
```

## Development Notes
* [Test Coverage Reports](https://app.codecov.io/gh/bguan/grafon) – aim for 100%.
