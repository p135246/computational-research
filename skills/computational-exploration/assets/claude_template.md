# {{PROJECT_NAME}}

## Project goals

{{GOALS}}

## Two approaches

- **Purely metric / structural**: Work with the discrete structure directly — graph distances, combinatorial properties, local neighborhoods. Push this as far as possible before introducing continuous or spectral tools.
- **Spectral / analytic**: Use the graph Laplacian, curvature notions, spectral embeddings, and other analytic tools to capture phenomena that the combinatorial structure alone cannot express.

The interplay between these two approaches is a central question: when does the analytic structure give genuinely new information beyond what the combinatorics provides?

## Code structure

- `Code/Tools.wl` — shared general utilities

Each topic scope can have:
- `Code/<Topic>.wl` — core functions (add-topic)
- `Code/<Topic>Visualization.wl` — visualization (add-topic)
- `Code/<Topic>Experiment.wl` — experiments (make-experiment)
- `Code/<Topic>Test.wl` — tests with VerificationTest + TestReport (make-test)

Initial topic: `{{PROJECT_NAME}}`

Notebooks: `<Topic>1.nb` per topic, `Test1.nb` for tests.

## Resources

`Resources/` — reference papers and community notebooks, named as `Author_Year_Title.pdf` or `.nb`
`Resources1.nb` — paper summaries notebook (one section per paper)

## Notes

`Article/article1.tex` — LaTeX article scaffold (user writes here, drawing from notes1.tex)
`Article/notes1.tex` — article-form working notes (Claude writes here when asked; source material for the article)
`Article/references.bib` — BibTeX references

## Loading code

```wolfram
SetDirectory[NotebookDirectory[]]
Get["Code/Tools.wl"]
Get["Code/{{PROJECT_NAME}}.wl"]
Get["Code/{{PROJECT_NAME}}Visualization.wl"]
```
