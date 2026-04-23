# Synapse Quote Creation

Este projeto é uma aplicação em Flutter que permite a criação de documentos de cotação e laudos técnicos.

## 🛠️ Funcionalidades

-   **Interface Gráfica**: Interface moderna desenvolvida com **Flutter**.
-   **Banco de Dados**: Banco de dados local para armazenamento de cotações e laudos técnicos.
-   **PDF**: Geração de documentos PDF para cotações e laudos técnicos.
-   **Compartilhamento**: Compartilhamento de documentos PDF por e-mail, WhatsApp, etc.

O aplicativo foi pensado para ser executado em dispositivos móveis (Android e iOS), mas também pode ser executado em desktops (Windows, macOS e Linux).

## 📁 Estrutura do Projeto

-   `lib/main.dart`: Arquivo principal que contém a interface gráfica e a lógica de interação com o usuário.
-   `lib/models/quote_model.dart`: Modelo de dados para cotações e laudos técnicos.
-   `lib/services/database_helper.dart`: Helper para o banco de dados SQLite.
-   `lib/services/pdf_service.dart`: Helper para geração de PDFs.
-   `views/quote_list_view.dart`: Lista de cotações e laudos técnicos.
-   `views/quote_form_view.dart`: Formulário para criação de cotações e laudos técnicos.

## 📷 Imagens do Projeto

### Tela Principal
Nesta página, é possível visualizar todos os documentos salvos.

![Document List View](/images/document-list-view.png)

### Formulário
Nesta página, é possível criar um novo documento ou editar um documento existente.

![Document Edit View](/images/document-edit-view.png)

## Configurações
Aqui, é possível configurar os dados da empresa que serão utilizados nos PDF's que serão gerados.

![Document Config View](/images/document-config-view.png)

### PDF Gerado
Por último, um exemplo de como o PDF é gerado.

![Document PDF](/images/generated-pdf.png)

---
*Developed by [Diego Freire](https://github.com/diegofreiregit)*