# miniAna
An Igor Pro procedure with offers an analytical environment for miniature events, written to analyze miniature EPSCs recorded in in vitro brain slice preparation of mice. Several parameters are obtained on each event (timestamps, amplitude, decay time, interevent interval etc) and the parameters can be exported as a comma-separated value file. Averaged trace of recorded events can also be prepared as a graph.

## Getting Started

### Prerequisites
* tUtility (https://github.com/yuichi-takeuchi/tUtility)
* SetWindowExt.XOP (http://fermi.uchicago.edu/freeware/LoomisWood/SetWindowExt.shtml)

This code has been tested in Igor Pro version 6.3.7.2. for Windows and supposed to work in Igor Pro 6.1 or later.

### Installing
1. Install Igor Pro 6.1 or later.
2. Put GlobalProcedure.ipf of tUtility or its shortcut into the Igor Procedures folder, which is normally located at My Documents\WaveMetrics\Igor Pro 6 User Files\Igor Procedures.
3. SetWindowExt.xop or its shortcut into the Igor Extensions folder, which is normally located at My Documents\WaveMetrics\Igor Pro 6 User Files\Igor Extensions.
4. Optional: SetWindowExt Help.ipf or its shortcut into the Igor Help Files folder, which is normally located at My Documents\WaveMetrics\Igor Pro 6 User Files\Igor Help Files.
5. Put miniAna.ipf or its shortcut into the Igor Procedure folder.
6. Restart Igor Pro.

### How to initialize the miniAna GUI
* Click "MiniAnaMain" in "MiniAna" of Menu.
* "MiniAnaMain", "MiniAnaParentGraph", "MiniAnaDaughterGraph", "MiniAnaEventGraph", and "MiniAnaTable" windows will appear.

### How to use
1. Set ExpRecNum (experiment record number), Sampling rate, and other parameters on the Set tab of the MiniAnaMain window. Mode can be selected either "Evoked Mini" (strontium experiment etc.) or "Mini or Sponta".
2. Set event detection patermeters (eg. polarity, amplitude) on the Detect tab of the MiniAnaMain window.
3. Get or edit the target wave list (source waves) onto the list box on the Main tab of the MiniAnaMain window.
4. Click "TablePrep" button on the MiniAnaTable window. The destination parameter table will appear on the window.
5. Click "Display" button on the Main tab of the MiniAnaMain window.
6. Click "AutoSearch" button on the Main tab of the MiniAnaMain window. If you do as Shift + AutoSearch, only preparation of manual detection of the target wave but not auto-search of events will occur.
7. Optional: Shift + "Scale" button on the MiniAnaDaughterGraph window for typical graph scaling.
8. After auto-search of events, do manual curation using "IsoAdAll", "CoAdAll", "IsoMdAll", "CoMdAll", "Delete", and "IsoTag" buttons or similar commands on the Marquee menu on the MiniAnaDaughterGraph. Iso and Co mean isolated and complex events, respectively. Complex events will not used for averaged event wave form. Ad means addition, which add a new event to the MiniAnaTable. Md means modify, which modify an already existing event on the table.
9. Move on the next target wave on the target wave list by clicking "Next Sw" button on the MinianaDaughterGraph window. 
10. Repeat 6 to 8 one-by-one for each target wave or click "AllSearch" button on the Main tab of the MiniAnaMain window.
11. Click "EditT0" button on the MiniAnaTable window to make a summary table.
12. Click "SaveTable" button on the MiniAnaTable window to export the summary table as a csv file.
13. "EventSum", "EventSumIX", and "EventSumAv" buttons on the MiniAnaTable will create and display an averaged wave from isolated events.

### Shortcut keys
The following shortcut keys are available on the MiniAnaDaughterGraph window. 

*During Marquee*
* A: IsoAdAll
* Shift + A: CoAdAll
* M: IsoMdAll
* Shift + M: CoMdAll

*Others*
* D: Delete
* N: Next
* C: LableW = NaN
* E: EraceCursors

### Help
* Click "Help" in "MiniAna" of Menu.

## DOI
[![DOI](https://zenodo.org/badge/93521372.svg)](https://zenodo.org/badge/latestdoi/93521372)

## Versioning
We use [SemVer](http://semver.org/) for versioning.

## Releases
* Ver 1.0.0, 2017/06/07
* Prerelease, 2017/06/06

## Authors
* **Yuichi Takeuchi PhD** - *Initial work* - [GitHub](https://github.com/yuichi-takeuchi)
* Affiliation: Department of Physiology, University of Szeged, Hungary
* E-mail: yuichi-takeuchi@umin.net

## License
This project is licensed under the MIT License.

## Acknowledgments
* Department of Physiology, Tokyo Women's Medical University, Tokyo, Japan
* Department of Information Physiology, National Institute for Physiological Sciences, Okazaki, Japan

## References
miniAna has been used for the following works:
* Takeuchi Y, Yamasaki M, Nagumo Y, Imoto K, Watanabe M, Miyata M (2012) Rewiring of afferent fibers in the somatosensory thalamus of mice caused by peripheral sensory nerve transection. J Neurosci 32:6917-6930.
* Takeuchi Y, Asano H, Katayama Y, Muragaki Y, Imoto K, Miyata M (2014) Large-scale somatotopic refinement via functional synapse elimination in the sensory thalamus of developing mice. J Neurosci 34:1258-1270.
* Takeuchi Y, Osaki H, Yagasaki Y, Katayama Y, Miyata M (2017) Afferent Fiber Remodeling in the Somatosensory Thalamus of Mice as a Neural Basis of Somatotopic Reorganization in the Brain and Ectopic Mechanical Hypersensitivity after Peripheral Sensory Nerve Injury. eNeuro 4:e0345-0316.
