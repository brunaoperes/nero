# 📍 Busca de Localização - 100% GRATUITO

O Nero usa **OpenStreetMap Nominatim** para busca de localizações - **totalmente gratuito, sem limites e sem necessidade de API Key**!

## 🎯 Funcionalidades

- ✅ **100% Gratuito** - Sem custos, sem limites
- 🔍 **Autocompletar em tempo real** conforme digita
- 📍 **Sugestões inteligentes** de lugares e endereços
- 🗺️ **Mini mapa** mostrando a localização selecionada
- 🌍 **OpenStreetMap** - Dados open source e atualizados pela comunidade
- 🇧🇷 **Otimizado para Brasil** com filtro de país
- 💾 **Armazena coordenadas GPS** para precisão total

## 🚀 Como usar

**Nada para configurar!** O sistema já está pronto para uso.

### Testar agora:

1. Execute o app: `flutter run -d chrome`
2. Crie uma nova tarefa
3. Clique em **"Adicionar Localização"**
4. Digite "MyConcords" ou qualquer lugar
5. Veja as sugestões aparecerem!

## 🎨 Experiência do usuário:

1. **Digite 3+ caracteres** (ex: "MyConcords")
   - Sistema busca automaticamente na API do OpenStreetMap

2. **Sugestões aparecem em tempo real**
   - Nome do lugar (ex: "MyConcords Café")
   - Endereço completo (ex: "Rua Bernardino de Campos - São José do Rio Preto")

3. **Selecione uma sugestão**
   - Mini mapa aparece mostrando o local exato
   - Informações completas do lugar

4. **Clique em "Confirmar Localização"**
   - Coordenadas GPS são salvas
   - Nome e endereço ficam vinculados à tarefa

5. **Botão "Abrir no Mapa"**
   - Abre Google Maps com as coordenadas precisas
   - Funciona em web, Android e iOS

## 🆚 Comparação: OpenStreetMap vs Google Places

| Recurso | OpenStreetMap Nominatim | Google Places API |
|---------|------------------------|-------------------|
| **Custo** | **100% Gratuito** | $200/mês grátis, depois pago |
| **API Key** | **Não precisa** | Precisa configurar |
| **Limites** | **Sem limites** | 100.000 req/mês grátis |
| **Qualidade** | Muito boa | Excelente |
| **Open Source** | ✅ Sim | ❌ Não |
| **Setup** | **Zero configuração** | Criar projeto no Google Cloud |
| **Países** | 🌍 Mundo todo | 🌍 Mundo todo |

## 🏗️ Arquitetura técnica

### Serviço NominatimService
- **Localização**: `lib/core/services/nominatim_service.dart`
- **API Base**: `https://nominatim.openstreetmap.org`
- **Métodos**:
  - `searchPlaces()` - Busca lugares pelo nome
  - `reverseGeocode()` - Coordenadas → Endereço

### Widget FreeLocationPicker
- **Localização**: `lib/features/tasks/presentation/widgets/free_location_picker.dart`
- **Recursos**:
  - Autocompletar com debounce (500ms)
  - Animações suaves (fade + slide)
  - Mini mapa Google Maps
  - Suporte dark/light theme
  - Loading states
  - Tratamento de erros

## 📊 Dados retornados

Para cada lugar encontrado, você recebe:

```dart
class NominatimPlace {
  String placeId;           // ID único do lugar
  String displayName;       // Nome completo formatado
  double latitude;          // Coordenada GPS
  double longitude;         // Coordenada GPS
  String? name;             // Nome do estabelecimento
  String? road;             // Nome da rua
  String? houseNumber;      // Número do endereço
  String? neighbourhood;    // Bairro
  String? city;             // Cidade
  String? state;            // Estado
  String? country;          // País
  String? postcode;         // CEP
  String type;              // Tipo (cafe, restaurant, etc)
}
```

## 💡 Exemplos de busca

### Estabelecimentos:
- "Starbucks São Paulo"
- "Banco do Brasil"
- "Shopping Iguatemi"

### Endereços completos:
- "Rua Bernardino de Campos, 3250"
- "Avenida Paulista 1000"
- "Praça da Sé"

### Pontos de referência:
- "Maracanã"
- "Cristo Redentor"
- "Museu do Ipiranga"

## 🚀 Upgrade futuro (opcional)

Se no futuro você quiser uma busca ainda mais precisa:

### Opção 1: Google Places API
- Qualidade superior
- Fotos dos lugares
- Horários de funcionamento
- Avaliações
- **Custo**: $200/mês grátis

### Opção 2: Mapbox Places
- Muito bom
- Tier gratuito generoso
- **Custo**: 100.000 req/mês grátis

### Opção 3: HERE Places
- Boa qualidade
- Tier gratuito
- **Custo**: 1.000 req/dia grátis

**Migração fácil**: O código está preparado para trocar o backend mantendo a mesma interface.

## 🔧 Política de uso do Nominatim

O OpenStreetMap pede apenas:

1. ✅ **Use um User-Agent** (já configurado no código)
2. ✅ **Máximo 1 requisição por segundo** (já implementado com debounce)
3. ✅ **Não fazer cache massivo** (não fazemos)

Seguindo essas regras simples, você pode usar **ilimitadamente e gratuitamente**!

## 📚 Documentação oficial

- [Nominatim Documentation](https://nominatim.org/release-docs/latest/)
- [OpenStreetMap Wiki](https://wiki.openstreetmap.org/wiki/Nominatim)
- [Usage Policy](https://operations.osmfoundation.org/policies/nominatim/)

## ❓ FAQ

### Q: Preciso criar conta no OpenStreetMap?
**R:** Não! A API é totalmente pública e gratuita.

### Q: Tem limite de requisições?
**R:** Recomendação de 1 req/segundo, mas para uso normal não há limites.

### Q: Funciona offline?
**R:** Não, precisa de internet para buscar. Os dados salvos (coordenadas) funcionam offline.

### Q: Os dados são atualizados?
**R:** Sim! OpenStreetMap é atualizado diariamente pela comunidade global.

### Q: Posso usar comercialmente?
**R:** Sim! É 100% livre para uso comercial.

---

**Pronto para usar!** 🎉 Sem configuração, sem custo, sem limites!
