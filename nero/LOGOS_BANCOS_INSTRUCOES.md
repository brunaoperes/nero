# Instruções para Adicionar Logos Reais dos Bancos

## 📁 Estrutura de Pastas

Os logos devem ser salvos em:
```
assets/images/banks/
```

## 🎨 Formato e Nomenclatura

- **Formato**: PNG com fundo transparente (recomendado) ou SVG
- **Tamanho**: 512x512px ou 1024x1024px para melhor qualidade
- **Nome do arquivo**: Use o `key` do banco (minúsculas)

Exemplo:
```
assets/images/banks/nubank.png
assets/images/banks/itau.png
assets/images/banks/bradesco.png
assets/images/banks/caixa.png
assets/images/banks/santander.png
assets/images/banks/c6.png
assets/images/banks/inter.png
assets/images/banks/xp.png
assets/images/banks/wallet.png
assets/images/banks/poupanca.png
assets/images/banks/generic.png
```

## 🔗 Onde Encontrar os Logos

### Opção 1: Sites Oficiais dos Bancos (Melhor Qualidade)
- **Nubank**: https://nubank.com.br/imprensa/
- **Itaú**: https://www.itau.com.br/sobre/marca/
- **Bradesco**: https://banco.bradesco/html/classic/sobre-o-bradesco/imprensa/logos.shtm
- **Caixa**: https://www.caixa.gov.br/Downloads/
- **Santander**: https://www.santander.com.br/institucional/identidade-visual
- **C6 Bank**: https://www.c6bank.com.br/
- **Inter**: https://www.bancointer.com.br/
- **XP**: https://www.xpi.com.br/

### Opção 2: Repositórios Open Source
- **GitHub - Brazilian Banks Logos**: https://github.com/TheDevFactory/BrazilianBanks
- **Brandfetch**: https://brandfetch.com/ (busque pelo nome do banco)
- **Clearbit Logo API**: https://logo.clearbit.com/:domain (ex: logo.clearbit.com/nubank.com.br)

### Opção 3: Flaticon / Iconfinder (Ícones Genéricos)
Para ícones genéricos como "Carteira" e "Poupança":
- https://www.flaticon.com/
- https://www.iconfinder.com/

## 📝 Checklist de Implementação

- [ ] Baixar os 11 logos dos bancos
- [ ] Salvar na pasta `assets/images/banks/`
- [ ] Renomear com nomes corretos (nubank.png, itau.png, etc.)
- [ ] Verificar se os arquivos têm fundo transparente
- [ ] Executar `flutter pub get` após adicionar os assets

## 🎨 Recomendações de Design

1. **Fundo Transparente**: Essencial para se adaptar ao tema claro/escuro
2. **Proporção**: Manter proporção quadrada (1:1)
3. **Formato**: PNG é mais compatível, mas SVG oferece melhor escalabilidade
4. **Tamanho**: Entre 512x512px e 1024x1024px (o Flutter redimensiona automaticamente)

## 🚀 Exemplo de Uso no Código

Após adicionar os logos, o código automaticamente usará as imagens reais ao invés de emojis:

```dart
// Antes (emoji)
Text('💜', style: TextStyle(fontSize: 24))

// Depois (logo real)
Image.asset(
  'assets/images/banks/nubank.png',
  width: 32,
  height: 32,
  fit: BoxFit.contain,
)
```

## ⚠️ Direitos Autorais

Os logos dos bancos são marcas registradas de suas respectivas empresas. Use apenas para:
- Fins pessoais
- Identificação de contas bancárias no app
- Não comercialize ou redistribua os logos

---

**Dica**: Se não quiser baixar manualmente, você pode usar a API do Clearbit:
```
https://logo.clearbit.com/nubank.com.br
https://logo.clearbit.com/itau.com.br
https://logo.clearbit.com/bradesco.com.br
```

E o Flutter pode carregar imagens da internet com `Image.network()`.
