#!/usr/bin/env python3
"""
Health check script for Memori deployment.
Returns exit code 0 if healthy, 1 if unhealthy.
"""

import sys
import os

def check_import():
    """Check if memori can be imported."""
    try:
        import memori
        print(f"✓ Memori imported successfully (version: {memori.__version__})")
        return True
    except ImportError as e:
        print(f"✗ Failed to import memori: {e}")
        return False

def check_dependencies():
    """Check if critical dependencies are available."""
    dependencies = {
        'openai': 'OpenAI',
        'litellm': 'LiteLLM',
        'sqlalchemy': 'SQLAlchemy',
        'pydantic': 'Pydantic',
    }
    
    all_ok = True
    for module, name in dependencies.items():
        try:
            __import__(module)
            print(f"✓ {name} available")
        except ImportError:
            print(f"✗ {name} not available")
            all_ok = False
    
    return all_ok

def check_database():
    """Check if database connection is configured."""
    db_string = os.getenv('MEMORI_DATABASE__CONNECTION_STRING')
    if db_string:
        print(f"✓ Database configured: {db_string.split('://')[0]}")
        return True
    else:
        print("ℹ Database not explicitly configured (will use default SQLite)")
        return True

def check_api_keys():
    """Check if API keys are configured."""
    openai_key = os.getenv('OPENAI_API_KEY')
    if openai_key and openai_key.startswith('sk-'):
        print("✓ OpenAI API key configured")
        return True
    else:
        print("⚠ OpenAI API key not configured (some features may not work)")
        return True  # Not critical for health check

def main():
    """Run all health checks."""
    print("Running Memori Health Checks...")
    print("-" * 50)
    
    checks = [
        ("Import Check", check_import),
        ("Dependencies Check", check_dependencies),
        ("Database Check", check_database),
        ("API Keys Check", check_api_keys),
    ]
    
    results = []
    for name, check in checks:
        print(f"\n{name}:")
        result = check()
        results.append(result)
    
    print("\n" + "=" * 50)
    if all(results):
        print("✓ All health checks passed!")
        return 0
    else:
        print("✗ Some health checks failed")
        return 1

if __name__ == "__main__":
    sys.exit(main())
