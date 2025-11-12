# Assets do Nero

Esta pasta contém todos os recursos estáticos do aplicativo.

## 📁 Estrutura

### `/images`
Imagens e ilustrações do app
- Logo do Nero (formato PNG e SVG)
- Ilustrações de empty states
- Backgrounds
- Imagens promocionais

### `/icons`
Ícones personalizados
- Ícones customizados (SVG)
- Ícones de categorias
- Ícones de badges

### `/animations`
Animações Lottie
- Animações de loading
- Animações de sucesso/erro
- Animações de onboarding

### `/fonts`
Fontes customizadas (se necessário)
- Inter (já incluída via Google Fonts)
- Poppins (já incluída via Google Fonts)

## 📥 Assets Necessários

Para começar o desenvolvimento, adicione:

1. **Logo do Nero** (`images/logo.png`)
   - Tamanho: 512x512px
   - Formato: PNG com fundo transparente
   - Cores: Azul elétrico (#0072FF) e dourado (#FFD700)

2. **App Icon** (`images/app_icon.png`)
   - Tamanho: 1024x1024px
   - Formato: PNG
   - Use o pacote `flutter_launcher_icons` para gerar

3. **Splash Screen** (`images/splash.png`)
   - Vários tamanhos para diferentes densidades
   - Use o pacote `flutter_native_splash`

## 🎨 Recursos Gratuitos

Você pode encontrar recursos gratuitos em:
- **Ilustrações**: https://undraw.co
- **Ícones**: https://heroicons.com, https://phosphoricons.com
- **Animações Lottie**: https://lottiefiles.com
- **Imagens**: https://unsplash.com

## ⚙️ Configuração

Após adicionar os assets:

1. Verifique se estão listados em `pubspec.yaml`
2. Execute `flutter pub get`
3. Os assets estarão disponíveis via `AssetImage` ou `SvgPicture`

## 📌 Notas

- Mantenha tamanhos de arquivo pequenos (otimize PNGs e SVGs)
- Use SVG sempre que possível (escalável)
- Nomeie arquivos com snake_case (ex: `empty_state_tasks.png`)
- Organize em subpastas se necessário
