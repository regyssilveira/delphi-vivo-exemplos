# Checklist de rollback

- [ ] candidato, commit, plataforma e schema registrados;
- [ ] pacote anterior disponível e hash verificado;
- [ ] backup do banco restaurado em laboratório;
- [ ] compatibilidade entre versão anterior e schema novo confirmada;
- [ ] efeitos fiscais e financeiros externos identificados;
- [ ] responsável pela decisão e canal de comunicação definidos;
- [ ] `build/rollback.ps1` ensaiado em diretório descartável;
- [ ] smoke test executado depois do retorno;
- [ ] operações ocorridas durante a janela reconciliadas;

Rollback do executável não desfaz automaticamente emissão fiscal, cobrança ou alteração destrutiva de dados. Esses efeitos exigem procedimento próprio.
