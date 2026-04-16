# Android, AOSP e Custom ROMs — Notas e Insights

## Contexto: Zenfone 9 vs Pixel 8

### Comparação direta (troca 0-0)

| Aspecto | Zenfone 9 (256GB/8GB) | Pixel 8 (128GB/8GB) |
|---|---|---|
| Chip | Snapdragon 8+ Gen 1 | Tensor G3 |
| Lançamento | Set/2022 | Out/2023 |
| Armazenamento | 256GB | 128GB |
| Tamanho | 5.9" (compacto) | 6.2" |
| Updates | ~2025 | até 2030 (7 anos) |
| Bootloader | **Permanentemente locked** | Desbloqueável facilmente |
| Custom ROM | Inviável | Excelente suporte |

### Por que o Zenfone 9 tem bootloader locked permanente?

Asus regrediu da política do Zenfone 8 (que tinha unlock oficial) sem explicação clara. Motivos prováveis:

- **Certificação Widevine L1** — fabricantes perdem a certificação (Netflix em HD, DRM) se facilitam unlock
- Redução de custo de suporte (menos bricks, menos reclamações)
- Possível pressão de operadoras em alguns mercados

A comunidade XDA ficou bem insatisfeita na época. Foi uma decisão de negócio que prejudicou o usuário avançado sem compensação.

### Por que o Pixel usa Tensor em vez de Snapdragon?

Estratégia de integração vertical — Google quer controlar hardware + software + IA do zero, como a Apple faz com os chips A-series. O Tensor é otimizado para workloads de ML/IA (transcrição, câmera, Gemini on-device, Call Screen).

**Execução problemática até agora:** Tensor G3 esquenta mais e é menos eficiente que Snapdragon equivalente. A aposta estratégica é certa no longo prazo, mas mal executada nas primeiras gerações.

---

## Android / AOSP — Internals

### Linguagens usadas

| Camada | Linguagem |
|---|---|
| Kernel Linux | C |
| HAL / libs nativas | C / C++ |
| Framework Android | Java (histórico) + Kotlin |
| Tooling / build scripts | Python, Shell, Go |
| Componentes novos | **Rust** (Google migrando ativamente por segurança de memória) |

A migração para Rust é uma decisão estratégica do Google para eliminar classes inteiras de vulnerabilidades de memória (buffer overflow, use-after-free etc.) em componentes críticos do sistema.

### Repositório AOSP

O AOSP **não fica no GitHub**. Usa infraestrutura própria:

- **Fonte oficial:** `android.googlesource.com`
- **Code review:** Gerrit (não Pull Requests)
- **Gerenciamento:** ferramenta `repo` — o AOSP são **centenas de repositórios** organizados por um manifesto XML

Existem mirrors no GitHub mas não são oficiais e ficam desatualizados.

### Compilando AOSP / Custom ROM — Fluxo básico

```bash
# 1. Instalar ferramenta repo
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod +x ~/bin/repo

# 2. Sincronizar sources (~100GB+)
repo init -u https://android.googlesource.com/platform/manifest -b android-14.0.0_r1
repo sync -j$(nproc)

# 3. Configurar ambiente
source build/envsetup.sh

# 4. Selecionar target
lunch aosp_arm64-eng
# Para LineageOS:
breakfast <codename>

# 5. Compilar
m -j$(nproc)
# Para LineageOS:
brunch <codename>
```

**Requisitos de hardware:**
- Disco: ~300GB+ (sources + build output)
- RAM: mínimo 16GB, recomendado 32GB+
- Tempo de build: 2-6h na primeira vez, muito menos nas subsequentes (incremental)
- SO: Ubuntu LTS (ambiente oficial)

---

## Custom ROMs — Ecossistema

### Principais ROMs

| ROM | Foco | Observação |
|---|---|---|
| **LineageOS** | Uso geral, privacidade básica | Maior comunidade, mais devices suportados |
| **GrapheneOS** | Segurança e privacidade máxima | **Apenas Pixels**, padrão ouro de segurança |
| **CalyxOS** | Privacidade + usabilidade | Foco em microG (alternativa ao Google Play Services) |

### Pixels: Snapdragon vs Tensor para custom ROM

Na prática faz pouca diferença — Pixels são o hardware mais amigável pra ROMs independente do chip. Nuances:

**Snapdragon (Pixel 1–5a):**
- Kernel mais maduro no ecossistema de ROMs
- Hardware mais antigo, muitos fora de suporte do Google
- Mais barato

**Tensor (Pixel 6+):**
- Google mantém kernel ativamente
- Mais longevidade de suporte oficial
- Titan M2 (chip de segurança) bem integrado nas ROMs modernas
- GrapheneOS suporta com excelência

### Pixel 6a — O dispositivo curinga

Melhor custo-benefício para laboratório de custom ROM:

- Tensor G1
- Suportado por GrapheneOS, LineageOS, CalyxOS
- Preço acessível no mercado usado
- Ainda recebe atualizações do Google
- Documentação e comunidade abundantes

**Pixel 7a** é o próximo nível — Tensor G2 melhorado, mais longevidade.

### Alternativas ao Pixel (para o mercado brasileiro)

O mercado brasileiro de Pixels usados é inflacionado (sem venda oficial, importados). Alternativas viáveis para o mesmo objetivo:

- **Motorola (Edge/Moto G):** LineageOS suporta alguns modelos, bootloader desbloqueável oficialmente
- **Xiaomi/Redmi/POCO:** Comunidade enorme de custom ROM, bootloader desbloqueável (tem período de espera burocrático de dias)
- **OnePlus (modelos antigos):** Historicamente muito amigável, difícil de achar no Brasil

Para **aprender a buildar ROM**, qualquer device bem suportado pelo LineageOS serve — não precisa ser Pixel.

---

## Dificuldade de Compilar ROMs — Escala prática

### Para device com suporte oficial (ex: Pixel no LineageOS)

**Compilar sem modificar:** surpreendentemente tranquilo, quase mecânico. Projeto de fim de semana viável pra quem tem familiaridade com terminal Linux.

**A dificuldade sobe com as modificações:**
- Entender a estrutura de diretórios do AOSP tem curva de aprendizado
- Patches mal feitos quebram outras coisas
- Erros de build às vezes são crípticos

### Para device que perdeu suporte oficial

Depende do motivo da perda de suporte:

**Cenário 1 — Ninguém manteve (mais comum, dificuldade: média)**
- Device tree existe mas não foi atualizado para a nova branch
- Você pega o device tree da branch antiga e tenta compilar na nova
- Aparecem erros de API quebrada, interfaces mudadas, coisas renomeadas
- Vai corrigindo erro por erro — trabalhoso mas guiado
- Viável com experiência de terminal e disposição pra ler código

**Cenário 2 — Problema de kernel (dificuldade: alta)**
- Kernel do device precisa de patches que a versão nova exige
- Exige conhecimento de kernel Linux — C, patches, backports
- Barreira significativamente mais alta

**Cenário 3 — Blobs proprietários quebrados (dificuldade: variável)**
- Fabricante nunca atualizou drivers fechados
- Às vezes contornável, às vezes bloqueio real

### Caminho de aprendizado recomendado

```
1. Compilar ROM para device suportado (sem modificar)
     ↓
2. Fazer pequenas customizações
     ↓
3. Portar device tree de branch antiga para nova
     ↓
4. Mexer em kernel
```

O passo 3 já é realizável sem ser expert — é mais persistência do que genialidade.

---

## Longevidade prática de um Android

A versão do Android em si raramente é o que torna um device obsoleto no uso diário. O que importa monitorar:

- **Security patch:** se o fabricante parar de mandar patches, apps de banco com root detection/SafetyNet agressivo podem começar a reclamar
- **Versão mínima de API:** apps definem versão mínima de Android — o A14 ainda está longe de ser barrado em qualquer coisa relevante (~3-4 anos de margem)
- Com custom ROM ativa, a longevidade prática do hardware aumenta significativamente

---

## Referências úteis

- [android.googlesource.com](https://android.googlesource.com) — AOSP oficial
- [LineageOS Devices](https://wiki.lineageos.org/devices/) — lista de devices suportados oficialmente
- [GrapheneOS](https://grapheneos.org) — ROM focada em segurança (apenas Pixels)
- [XDA Developers](https://xda-developers.com) — comunidade de desenvolvimento de ROMs
