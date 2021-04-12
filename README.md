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
    final sun = SingleGram(Mono.Sun.gram); // or star
    expect(sun.toString(), "Sun");
    expect(sun.pronunciation, "Je");

    final angleUp = Quad.Angle.grams[Face.Up];
    final gateUp = Quad.Gate.grams[Face.Up];

    final house = SingleGram(angleUp).over(SingleGram(gateUp));
    expect(house.toString(), "Angle.Up / Gate.Up");
    expect(house.pronunciation, "GibDi");

    final dot = Mono.Dot.gram;
    final lineUp = Quad.Line.grams[Face.Up];

    final person = SingleGram(dot).over(SingleGram(lineUp));
    expect(person.toString(), "Dot / Line.Up");
    expect(person.pronunciation, "SebI");

    final lineDown = Quad.Line.grams[Face.Down];

    final day = sun.over(SingleGram(lineDown));
    expect(day.toString(), "Sun / Line.Down");
    expect(day.pronunciation, "JebU");

    final flowRight = Quad.Flow.grams[Face.Right];
    final rain = SingleGram(flowRight).before(SingleGram(flowRight));
    expect(rain.toString(), "Flow.Right | Flow.Right");
    expect(rain.pronunciation, "VaVa");

    final arcRight = Quad.Arc.grams[Face.Right];
    final flowUp = Quad.Flow.grams[Face.Up];
    final speech = SingleGram(arcRight).around(SingleGram(flowUp));
    expect(speech.toString(), "Arc.Right @ Flow.Up");
    expect(speech.pronunciation, "MamVi");

    final square = Mono.Square.gram;
    final nine = SingleGram(square).merge(SingleGram(lineUp));
    expect(nine.toString(), "Square ~ Line.Up");
    expect(nine.pronunciation, "DesI");

    final starMan = sun.compound(person); // God? Alien?
    expect(starMan.toString(), "Sun : Dot / Line.Up");
    expect(starMan.pronunciation, "JengSebI");
  });
```

## Development Notes
* [Test Coverage Reports](https://app.codecov.io/gh/bguan/grafon) – aim for 100%.
