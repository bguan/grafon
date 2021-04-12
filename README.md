# Grafon

A graphical phonetic language.  

Graphical symbols, arranged in a table, are each associated with a syllable (an optional starting 
consonant and a vowel).  

![Gra Table](/assets/images/gramtable.png)

The symbols can be further arranged in a handful of 2 dimensional operations to form words.

An unary operation manipulating a symbol is associated with an ending 
vowel to be appended to the end of the symbol.

A binary operation manipulating 2 symbols (or expressions) is associated with an ending 
consonant to be appended to the end of the first symbol (or expression).

## Example in Code
```
  test('BinaryExpr toString and pronunciation is correct', () {
    final sun = Mono.Sun.gram; // or star
    expect(sun.toString(), "Sun");
    expect(sun.pronunciation, "Je");

    final house = Quad.Angle.up.over(Quad.Gate.up);
    expect(house.toString(), "Angle.Up / Gate.Up");
    expect(house.pronunciation, "GisDi");

    final person = Mono.Dot.gram.over(Quad.Line.up);
    expect(person.toString(), "Dot / Line.Up");
    expect(person.pronunciation, "SesI");

    final day = sun.over(Quad.Line.down);
    expect(day.toString(), "Sun / Line.Down");
    expect(day.pronunciation, "JesU");

    final rain = Quad.Flow.down.before(Quad.Flow.down);
    expect(rain.toString(), "Flow.Down | Flow.Down");
    expect(rain.pronunciation, "VuVu");

    final speech = Quad.Arc.right.around(Quad.Flow.right);
    expect(speech.toString(), "Arc.Right @ Flow.Right");
    expect(speech.pronunciation, "MamVa");

    final nine = Mono.Square.gram.merge(Quad.Line.up);
    expect(nine.toString(), "Square * Line.Up");
    expect(nine.pronunciation, "DelI");

    final starMan = sun.compound(person); // God? Alien?
    expect(starMan.toString(), "Sun : Dot / Line.Up");
    expect(starMan.pronunciation, "JengSesI");
  });
```

## Development Notes
* [Test Coverage Reports](https://app.codecov.io/gh/bguan/grafon) – aim for 100%.
