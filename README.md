# cvsimporter

This is a tool for importing ORCA CVS repository to Git repository.


## Note

This software is not part of ORCA, and also not provided by ORCA Project.

**IMPORTANT** Make sure do not run this importer as many as frequently! Maybe once a day in midnight is better because `cvsps` causes high load on CVS server.

## How to use

1. Copy `git-cvsimport.orca` to `/path/to/git-core/git-cvsimport.orca` (for example, `/usr/lib/git-core/git-cvsimport.orca`)
2. Get `orcacvs` from [here](https://www.orca.med.or.jp/receipt/tec/cvs-jma-receipt.html)
3. Add an entry for `cvs.orca.med.or.jp` to `~/.ssh/config`
   ```
   Host cvs.orca.med.or.jp
       User anoncvs
       IdentityFile ~/.ssh/orcacvs
       Compression yes
       CompressionLevel 3
   ```

4. Clone cvsimporter
   ```
   git clone https://github.com/orcacvsmirror/cvsimporter.git
   ```

5. Run importer
   ```
   ./cvsimporter/import.sh <module>
   ```

6. `import.sh` will finally push to upstream, so for the first time you're required to set upstream `origin` to your own repository.


## References

1. [ORCA Project: 日本医師会総合政策研究機構](https://www.orca.med.or.jp/)
2. [ORCA Project: 技術情報](https://www.orca.med.or.jp/receipt/tec/)
3. [ORCA Project: CVS公開について (日医標準レセプトソフト)](https://www.orca.med.or.jp/receipt/tec/cvs-jma-receipt.html)
4. [ORCA Project: CVSweb](http://cvs.orca.med.or.jp/cgi-bin/cvsweb/)
