# Quick Start - Deploy Memori in 5 Minutes

This guide will get you up and running with Memori in under 5 minutes.

## Option 1: Docker (Recommended)

### Prerequisites
- Docker and Docker Compose installed
- OpenAI API key

### Steps

1. **Clone the repository:**
```bash
git clone https://github.com/GibsonAI/memori.git
cd memori
```

2. **Setup environment:**
```bash
./scripts/deploy.sh setup
```

Edit `.env` and add your OpenAI API key:
```bash
OPENAI_API_KEY=sk-your-key-here
```

3. **Start everything:**
```bash
./scripts/deploy.sh start
```

That's it! Access your services:
- 📚 **Documentation**: http://localhost:8000
- 📔 **Personal Diary**: http://localhost:8501
- 🔍 **Researcher**: http://localhost:8502
- ✈️ **Travel Planner**: http://localhost:8503
- 💼 **Job Search**: http://localhost:8504
- 🚀 **Product Launch**: http://localhost:8505

### Useful Commands

```bash
# View logs
./scripts/deploy.sh logs

# Stop services
./scripts/deploy.sh stop

# Restart services
./scripts/deploy.sh restart

# Check health
./scripts/deploy.sh health
```

## Option 2: Local Python Installation

### Prerequisites
- Python 3.10+
- OpenAI API key

### Steps

1. **Install Memori:**
```bash
pip install memorisdk
```

2. **Set environment variable:**
```bash
export OPENAI_API_KEY=sk-your-key-here
```

3. **Run a demo:**
```bash
git clone https://github.com/GibsonAI/memori.git
cd memori/demos/personal_diary_assistant
pip install -r requirements.txt
streamlit run streamlit_app.py
```

## Option 3: Streamlit Cloud (Free Hosting)

1. **Fork the repository** on GitHub

2. **Go to [Streamlit Cloud](https://share.streamlit.io/)**

3. **Deploy new app:**
   - Repository: `[your-username]/memori`
   - Branch: `main`
   - Main file: `demos/personal_diary_assistant/streamlit_app.py`

4. **Add secrets** in Streamlit Cloud settings:
```toml
OPENAI_API_KEY = "sk-your-key-here"
```

5. **Click Deploy!**

Your app will be live at: `https://[app-name].streamlit.app`

## Option 4: One-Click Cloud Deploy

### Railway
[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template)

### Render
[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

### Heroku
```bash
git clone https://github.com/GibsonAI/memori.git
cd memori/demos/personal_diary_assistant
heroku create
heroku config:set OPENAI_API_KEY=sk-your-key-here
git push heroku main
```

## Verify Installation

Test that Memori is working:

```python
from memori import Memori
from openai import OpenAI

# Initialize
memori = Memori(conscious_ingest=True)
memori.enable()

client = OpenAI()

# Test
response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": "Hello! My name is Alice."}]
)
print(response.choices[0].message.content)

# Test memory recall
response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": "What's my name?"}]
)
print(response.choices[0].message.content)  # Should mention "Alice"
```

## Troubleshooting

### Docker Issues

**Container won't start:**
```bash
# Check logs
docker-compose logs [service-name]

# Rebuild
docker-compose build --no-cache
```

**Port already in use:**
```bash
# Edit docker-compose.yml and change the port mapping
# For example: "8502:8501" instead of "8501:8501"
```

### Import Errors

**Can't import memori:**
```bash
# Reinstall
pip uninstall memorisdk
pip install memorisdk --upgrade
```

### API Key Issues

**OpenAI API errors:**
- Verify your API key is correct
- Check you have credits in your OpenAI account
- Ensure the key starts with `sk-`

### Database Issues

**SQLite locked errors:**
```bash
# Use PostgreSQL instead
export MEMORI_DATABASE__CONNECTION_STRING="postgresql://user:pass@localhost/memori"
```

## Next Steps

- 📖 Read the [full deployment guide](DEPLOYMENT.md)
- 🔧 Explore [configuration options](https://memorilabs.ai/docs/configuration/settings)
- 💬 Join our [Discord community](https://discord.gg/abD4eGym6v)
- ⭐ Star the [GitHub repo](https://github.com/GibsonAI/memori)

## Need Help?

- 📚 [Documentation](https://memorilabs.ai/docs)
- 💬 [Discord](https://discord.gg/abD4eGym6v)
- 🐛 [GitHub Issues](https://github.com/GibsonAI/memori/issues)
